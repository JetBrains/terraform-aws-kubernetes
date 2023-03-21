package test

import (
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test "github.com/gruntwork-io/terratest/modules/test-structure"
	"os"
	"path/filepath"
	"testing"
)

// ValidateModule todo: define the semantics
func ValidateModule(t *testing.T, path string) {
	terraformDir := path
	terraformPlanPath := filepath.Join(path, "test.tfplan")

	test.RunTestStage(t, "validate", func() {
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: terraformDir,
			PlanFilePath: terraformPlanPath,
			Lock:         true,
			EnvVars: map[string]string{
				"TF_LOG": "INFO",
				"TF_AWS_SKIP_REQUESTING_ACCOUNT_ID": "true",
				"TF_AWS_SKIP_CREDENTIALS_VALIDATION": "true",
				"TF_AWS_SKIP_METADATA_API_CHECK": "true",
				"TF_AWS_ACCESS_KEY": "mock_key",
				"TF_AWS_SECRET_KEY": "mock_secret_key",
			},
			Logger: logger.Discard,
		})
		test.SaveTerraformOptions(t, terraformDir, terraformOptions)
		test.ValidateAllTerraformModules(t, &test.ValidationOptions{
			RootDir: terraformDir,
		})
		terraform.InitAndPlanAndShow(t, terraformOptions)
	})

	test.RunTestStage(t, "cleanup", func() {
		var toCleanupFilesAndDirs = map[string]string{
			"dotTerraformDir":      filepath.Join(terraformDir, ".terraform"),
			"dotTestData":          filepath.Join(terraformDir, ".test-data"),
			"testPlan":             filepath.Join(terraformDir, "test.tfplan"),
			"dotTerraformLockFile": filepath.Join(terraformDir, ".terraform.lock.hcl"),
		}

		for item := range toCleanupFilesAndDirs {
			// Do not handle the error here
			_ = os.RemoveAll(toCleanupFilesAndDirs[item])
		}
	})
}

func TestEntrypoint(t *testing.T) {
	t.Parallel()
	cwd, _ := os.Getwd()
	testCasesDir := filepath.Join(cwd, "../../examples/*")

	if testCasesList, err := filepath.Glob(testCasesDir); err != nil {
		t.Fatalf("Failed to read the test cases")
	} else {
		for i := range testCasesList {
			ValidateModule(t, testCasesList[i])
		}
	}

}