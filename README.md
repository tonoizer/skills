# skills

Possible skills for my list could be 
- https://agent-browser.dev
- https://github.com/vercel-labs/skills/tree/main/skills/find-skills
- take peters skills + scripts: https://github.com/steipete/agent-scripts/tree/main
- https://github.com/addyosmani/agent-skills
- https://github.com/antfu/skills



/loop

(Könnte arbeite alle issues ab + monitor ci wenn grün dann merge wenn nicht fixen und warten bis morgen) 

/monitor-ci-and-fix

Das es auch auf commits auf CI trigger hurts oder sowas also Kombination solange bis alles grün ist

command: while true; do
  s=$(gh api repos/tonoizer/core/commits/9ab5d657a8dfeb0a5dd77c61d0b2d4a6f1d41ba0/check-runs --jq '[.check_runs[] | {name, status, conclusion}]' 2>/dev/null) || { sleep 60; continue; }
  echo "$s" | jq -r '.[] | select(.status=="completed") | "\(.name): \(.conclusion)"' | sort > /tmp/ci_cur_$$ 2>/dev/null
  comm -13 /tmp/ci_prev_$$ /tmp/ci_cur_$$ 2>/dev/null
  cp /tmp/ci_cur_$$ /tmp/ci_prev_$$ 2>/dev/null || touch /tmp/ci_prev_$$
  if echo "$s" | jq -e 'length > 0 and all(.status=="completed")' >/dev/null 2>&1; then echo "ALL CHECKS COMPLETED"; break; fi
  sleep 60
done




/code-review
/release-pr
/create-pr
/review-pr
/bug-repro


- More skills from warp
https://github.com/warpdotdev/oz-for-oss
https://github.com/warpdotdev-demos/cloud-factory-demo/tree/main
https://github.com/warpdotdev-demos/issue-triage-loop
https://github.com/warpdotdev-demos/pr-walkthrough-ci
https://github.com/warpdotdev-demos/resolve-merge-conflicts
