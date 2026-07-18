from __future__ import annotations

import contextlib
import importlib.util
import io
import stat
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


SKILL_DIR = Path(__file__).resolve().parents[1]
SCRIPTS_DIR = SKILL_DIR / "scripts"


def load_script(name: str):
    path = SCRIPTS_DIR / f"{name}.py"
    spec = importlib.util.spec_from_file_location(f"readout_{name}", path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


embed_snippets = load_script("embed_snippets")
validate_readout = load_script("validate_readout")


class CredentialSafetyTests(unittest.TestCase):
    def test_credential_prone_files_are_refused(self) -> None:
        for path in (".npmrc", ".netrc", ".pypirc", "config/auth.json"):
            with self.subTest(path=path):
                self.assertTrue(embed_snippets.sensitive(path))

    def test_authentication_source_directory_is_not_blanket_refused(self) -> None:
        for path in (
            "src/auth/controller.py",
            "src/token_service.py",
            "src/access_token.py",
            "src/credentials_manager.py",
            "docs/secrets-guide.md",
        ):
            with self.subTest(path=path):
                self.assertFalse(embed_snippets.sensitive(path))

    def test_common_unquoted_and_prefixed_tokens_are_refused(self) -> None:
        samples = (
            "API_KEY=abc123def456ghi789",
            "export ACCESS_TOKEN=abc123def456ghi789",
            "GITHUB_TOKEN=ghp_abcdefghijklmnopqrstuvwxyz123456",
            "token = github_pat_11AAabcdefghijklmnopqrstuvwxyz",
        )
        for sample in samples:
            with self.subTest(sample=sample):
                self.assertIsNotNone(embed_snippets.SECRET_CONTENT_RE.search(sample))

    def test_source_references_are_not_mistaken_for_literal_secrets(self) -> None:
        samples = (
            "token = configuration_value",
            'token = request.headers.get("Authorization")',
            'api_key = os.environ.get("OPENAI_API_KEY")',
            "client_secret: secret_reference",
            "token = oauth2_access_token",
            "token = sha256_digest_value",
            "api_key = config.api_v2_key",
            "password = password2_from_form",
        )
        for sample in samples:
            with self.subTest(sample=sample):
                self.assertIsNone(embed_snippets.SECRET_CONTENT_RE.search(sample))


class SourceLinkValidationTests(unittest.TestCase):
    def test_zero_source_line_is_invalid(self) -> None:
        url = "https://github.com/org/repo/blob/" + "a" * 40 + "/file.py#L0"
        self.assertEqual(validate_readout.blob_reference(url), "")


class StalePayloadTests(unittest.TestCase):
    def setUp(self) -> None:
        self.tempdir = tempfile.TemporaryDirectory()
        self.root = Path(self.tempdir.name)
        self.repo = self.root / "repo"
        self.commit = "a" * 40

    def tearDown(self) -> None:
        self.tempdir.cleanup()

    def run_embed(self, doc: Path) -> str:
        output = io.StringIO()
        argv = ["embed_snippets.py", str(doc), "--repo", str(self.repo)]
        with (
            mock.patch.object(sys, "argv", argv),
            mock.patch.object(embed_snippets, "repo_slug", return_value="example/private"),
            contextlib.redirect_stdout(output),
        ):
            self.assertEqual(embed_snippets.main(), 0)
        return output.getvalue()

    def document(self, *, include_link: bool = True) -> str:
        link = ""
        if include_link:
            link = (
                f'<a href="https://github.com/example/private/blob/{self.commit}/source.py#L2-L3">'
                "source</a>"
            )
        return (
            "<!doctype html><html><body>"
            + link
            + '<script type="application/json" data-code-snippets>\n'
            + '{"private":"source excerpt"}\n</script>\n'
            + "</body></html>"
        )

    def test_links_only_rerun_removes_existing_payload(self) -> None:
        doc = self.root / "links-only.html"
        doc.write_text(self.document(), encoding="utf-8")
        doc.chmod(0o640)

        output = self.run_embed(doc)

        self.assertIn("links only", output)
        self.assertNotIn("data-code-snippets", doc.read_text(encoding="utf-8"))
        self.assertEqual(stat.S_IMODE(doc.stat().st_mode), 0o640)

    def test_removing_all_citations_removes_existing_payload(self) -> None:
        doc = self.root / "no-citations.html"
        doc.write_text(self.document(include_link=False), encoding="utf-8")

        output = self.run_embed(doc)

        self.assertIn("nothing to embed", output)
        self.assertNotIn("data-code-snippets", doc.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
