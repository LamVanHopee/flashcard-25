import { danger, warn, fail, message } from "danger";
import { readFileSync, existsSync } from "fs";
import { diffLines } from "diff";

// 🪪 Check GitHub Token availability
if (!process.env.GITHUB_TOKEN && !process.env.DANGER_GITHUB_API_TOKEN) {
  warn("⚠️ No GitHub token detected. Danger will run in local mode and cannot post comments on the PR.");
} else {
  message("✅ GitHub token detected, PR comments will be posted successfully.");
}

// Warn if the PR is marked as WIP
if (danger.github.pr.title.includes("WIP")) {
  warn("PR is considered WIP");
}

// Warn if the PR description is empty
if (!danger.github.pr.body || danger.github.pr.body.length === 0) {
  warn("Please add a description to your PR.");
}

// Function to check lint results and report issues
const checkLintResults = (results) => {
  results.split('\n').forEach((line) => {
    if (line.includes('error')) {
      fail(`🐛 Flutter Lint Error: ${line}`);
    } else if (line.includes('info')) {
      warn(`⚠️ Flutter Lint Warning: ${line} - If it has fine you can ignore this comment.`);
    }
  });
};

// Read and check lint results from file
let lintResults = '';
try {
  lintResults = readFileSync('flutter_lint_results.txt', 'utf8');
  checkLintResults(lintResults);
} catch (error) {
  fail('Failed to read lint results file.');
  console.error(error);
}

// Check exported attribute in AndroidManifest diff
async function checkExportedAttributeInDiff() {
  const manifestFiles = danger.git.modified_files
    .concat(danger.git.created_files)
    .filter(f => f.includes("AndroidManifest.xml"));

  if (manifestFiles.length === 0) return;

  const diffPromises = manifestFiles.map(async file => {
    const diff = await danger.git.diffForFile(file);
    if (!diff) return false;
    return (
      diff.added.includes('android:exported="true"') ||
      diff.added.includes('android:exported="false"')
    );
  });

  const results = await Promise.all(diffPromises);
  if (results.includes(true)) {
    warn("⚠️ Detected changes to `android:exported` in AndroidManifest.xml. Please confirm they are safe.");
  }
}

// Compare merged manifest to baseline
async function checkExportedAttributeDiff() {
  const mergedManifestPath = "app/build/intermediates/merged_manifests/debug/AndroidManifest.xml";
  const baselineManifestPath = "manifest_snapshot/merged_manifest.xml";

  if (!existsSync(mergedManifestPath)) {
    warn("⚠️ Merged manifest not found. Please ensure the build step ran correctly.");
    return;
  }

  if (!existsSync(baselineManifestPath)) {
    warn("⚠️ No baseline manifest found. Please add `manifest_snapshot/merged_manifest.xml` to track future changes.");
    return;
  }

  const current = readFileSync(mergedManifestPath, "utf-8");
  const baseline = readFileSync(baselineManifestPath, "utf-8");

  const diff = diffLines(baseline, current);
  const exportedChanges = diff
    .filter(part => part.added || part.removed)
    .filter(part => part.value.includes("android:exported"));

  if (exportedChanges.length > 0) {
    const changeSummary = exportedChanges.map(part =>
      part.value
        .split("\n")
        .filter(line => line.trim() !== "")
        .map(line => (part.added ? `➕ ${line}` : `➖ ${line}`))
        .join("\n")
    ).join("\n");

    warn(`⚠️ Detected changes in \`android:exported\` attributes:\n\n\`\`\`\n${changeSummary}\n\`\`\`\nPlease review to ensure safety.`);
  } else {
    message("✅ No changes in android:exported attributes.");
  }
}

async function checkDecodedManifestDiff() {
  const decodedManifestPath = "manifest_snapshot/decoded_manifest.xml";
  const baselineDecodedManifestPath = "manifest_snapshot/baseline_decoded_manifest.xml";

  if (!existsSync(decodedManifestPath)) {
    warn("⚠️ Decoded APK manifest not found. Please ensure the decode step ran correctly.");
    return;
  }

  if (!existsSync(baselineDecodedManifestPath)) {
    warn("⚠️ No baseline decoded manifest found. Please add `manifest_snapshot/baseline_decoded_manifest.xml` to track future changes.");
    return;
  }

  const current = readFileSync(decodedManifestPath, "utf-8");
  const baseline = readFileSync(baselineDecodedManifestPath, "utf-8");

  const diff = diffLines(baseline, current);
  const exportedChanges = diff
    .filter(part => part.added || part.removed)
    .filter(part => part.value.includes("android:exported"));

  if (exportedChanges.length > 0) {
    const changeSummary = exportedChanges.map(part =>
      part.value
        .split("\n")
        .filter(line => line.trim() !== "")
        .map(line => (part.added ? `➕ ${line}` : `➖ ${line}`))
        .join("\n")
    ).join("\n");

    warn(`⚠️ Detected changes in \`android:exported\` attributes in APK decoded manifest:\n\n\`\`\`\n${changeSummary}\n\`\`\`\nPlease review to ensure safety.`);
  } else {
    message("✅ No changes in android:exported attributes in decoded APK manifest.");
  }
}

// Run all checks
(async () => {
  await checkExportedAttributeInDiff();
  await checkExportedAttributeDiff();
  await checkDecodedManifestDiff();
})();

markdown(`
### 📋 Manifest Baseline Checklist

- [ ] If your PR **changes AndroidManifest.xml**, you must regenerate the baseline after merge:

\`\`\`bash
./generate_baseline_manifest.sh
git add manifest_snapshot/baseline_decoded_manifest.xml
git commit -m "Update baseline manifest after merge"
git push origin main # or dev / app_release depending on your target branch
\`\`\`

👉 This ensures that Danger will not report false positives in future PRs.
`);