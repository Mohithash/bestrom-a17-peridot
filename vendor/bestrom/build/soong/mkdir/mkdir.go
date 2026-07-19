// Copyright (C) 2026 BestROM
// Minimal soong "mkdir" module for pure AOSP.
// Lineage trees use this type; pure AOSP does not ship it.
// Boot-safe: only creates empty dirs at install time — no HAL changes.

package mkdir

import (
	"android/soong/android"
	"path/filepath"
	"strings"

	"github.com/google/blueprint"
)

func init() {
	android.RegisterModuleType("mkdir", mkdirFactory)
}

type mkdirProperties struct {
	// Relative path under the install dir (e.g. "firmware")
	Dir *string
	// Optional: "vendor", "system", "odm", "product", "system_ext"
	// Default: vendor
	Partition *string
}

type mkdirModule struct {
	android.ModuleBase
	properties mkdirProperties
	output     android.Path
}

func mkdirFactory() android.Module {
	m := &mkdirModule{}
	m.AddProperties(&m.properties)
	android.InitAndroidArchModule(m, android.DeviceSupported, android.MultilibCommon)
	return m
}

func (m *mkdirModule) GenerateAndroidBuildActions(ctx android.ModuleContext) {
	dir := "empty"
	if m.properties.Dir != nil && *m.properties.Dir != "" {
		dir = *m.properties.Dir
	}
	// Keep path clean
	dir = strings.Trim(dir, "/")

	part := "vendor"
	if m.properties.Partition != nil && *m.properties.Partition != "" {
		part = *m.properties.Partition
	}

	// Stamp file that ninja depends on; install empty directory via soong install
	out := android.PathForModuleOut(ctx, "mkdir.stamp")
	ctx.Build(pctx, android.BuildParams{
		Rule:   mkdirRule,
		Output: out,
		Args: map[string]string{
			"dir": dir,
		},
		Description: "mkdir " + dir,
	})
	m.output = out

	// Install a .keep placeholder so the directory exists on device images
	// without wiping any existing vendor content (boot-safe).
	installDir := android.PathForModuleInstall(ctx, part, filepath.Dir(dir+"/.keep"))
	// If dir is multi-segment, install under partition root
	installDir = android.PathForModuleInstall(ctx, part)
	// Use InstallFile into dir/.keep
	ctx.InstallFile(android.PathForModuleInstall(ctx, part, dir), ".keep", out)
	_ = installDir
}

var (
	pctx      = android.NewPackageContext("android/soong/bestrom/mkdir")
	mkdirRule = pctx.StaticRule("bestromMkdir", blueprint.RuleParams{
		Command:     "mkdir -p $out && touch $out",
		Description: "bestrom mkdir stamp",
	})
)
