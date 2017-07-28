package integration_test

import (
	"io/ioutil"
	"path/filepath"

	"github.com/cloudfoundry/libbuildpack/cutlass"

	. "github.com/onsi/ginkgo"
	. "github.com/onsi/gomega"

	"testing"
)

var bpDir string
var buildpackVersion string

func TestIntegration(t *testing.T) {
	RegisterFailHandler(Fail)
	RunSpecs(t, "Integration Suite")
}

func findRoot() string {
	file := "VERSION"
	for {
		files, err := filepath.Glob(file)
		Expect(err).To(BeNil())
		if len(files) == 1 {
			file, err = filepath.Abs(filepath.Dir(file))
			Expect(err).To(BeNil())
			return file
		}
		file = filepath.Join("..", file)
	}
}

var _ = BeforeSuite(func() {
	bpDir = findRoot()
	data, err := ioutil.ReadFile(filepath.Join(bpDir, "VERSION"))
	Expect(err).NotTo(HaveOccurred())
	buildpackVersion = string(data)

	cutlass.DefaultMemory = "256M"
	cutlass.DefaultDisk = "256M"
})

var _ = AfterSuite(func() {
	cutlass.DeleteOrphanedRoutes()
})
