#!/usr/bin/env ruby
# Registers the VerseWidget Widget Extension target in Runner.xcodeproj.
# The extension's source/resource files already live in ios/VerseWidget/ —
# this script only wires them into the Xcode project (creating a native
# target, build phases, build settings, and embedding it in Runner) since
# hand-editing project.pbxproj is error-prone and hard to review.
#
# Usage: ruby ios/add_widget_extension.rb   (run from anywhere; paths are
# resolved relative to this file's location)

require 'xcodeproj'

TARGET_NAME = 'VerseWidget'
IOS_DIR = __dir__
PROJECT_PATH = File.join(IOS_DIR, 'Runner.xcodeproj')

project = Xcodeproj::Project.open(PROJECT_PATH)

if project.targets.any? { |t| t.name == TARGET_NAME }
  puts "#{TARGET_NAME} target already exists in #{PROJECT_PATH} — nothing to do."
  exit 0
end

runner_target = project.targets.find { |t| t.name == 'Runner' }
raise "Could not find the 'Runner' target in #{PROJECT_PATH}" unless runner_target

release_config = runner_target.build_configurations.find { |c| c.name == 'Release' }
host_bundle_id = release_config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']
widget_bundle_id = "#{host_bundle_id}.#{TARGET_NAME}"
app_group_id = "group.#{host_bundle_id}"

widget_dir = File.join(IOS_DIR, TARGET_NAME)
raise "Expected widget source files at #{widget_dir}, but that directory is missing" unless Dir.exist?(widget_dir)

runner_entitlements_path = File.join(IOS_DIR, 'Runner', 'Runner.entitlements')
widget_entitlements_path = File.join(widget_dir, "#{TARGET_NAME}.entitlements")
[runner_entitlements_path, widget_entitlements_path].each do |path|
  raise "Expected entitlements file at #{path}, but it is missing" unless File.exist?(path)
  unless File.read(path).include?(app_group_id)
    raise "#{path} does not declare the expected App Group '#{app_group_id}'"
  end
end

entry_view_file_name = "#{TARGET_NAME}EntryView.swift"
snapshot_test_file_name = "#{TARGET_NAME}SnapshotTests.swift"
entry_view_path = File.join(widget_dir, entry_view_file_name)
snapshot_test_path = File.join(IOS_DIR, 'RunnerTests', snapshot_test_file_name)
[entry_view_path, snapshot_test_path].each do |path|
  raise "Expected file at #{path}, but it is missing" unless File.exist?(path)
end

widget_group = project.main_group.new_group(TARGET_NAME, TARGET_NAME)

swift_file_names = ['AppIntent.swift', "#{TARGET_NAME}.swift", "#{TARGET_NAME}Bundle.swift", entry_view_file_name]
swift_refs = swift_file_names.map { |name| widget_group.new_file(name) }
entry_view_ref = swift_refs.find { |ref| ref.path == entry_view_file_name }
info_plist_ref = widget_group.new_file('Info.plist')
assets_ref = widget_group.new_file('Assets.xcassets')
widget_group.new_file("#{TARGET_NAME}.entitlements")

widget_target = project.new_target(:app_extension, TARGET_NAME, :ios, '17.0', widget_group, :swift)

swift_refs.each { |ref| widget_target.source_build_phase.add_file_reference(ref) }
widget_target.resources_build_phase.add_file_reference(assets_ref)

frameworks_group = project.frameworks_group
%w[WidgetKit SwiftUI].each do |framework|
  framework_ref = frameworks_group.new_file("System/Library/Frameworks/#{framework}.framework", :sdk_root)
  widget_target.frameworks_build_phase.add_file_reference(framework_ref)
end

widget_target.build_configurations.each do |config|
  settings = config.build_settings
  settings['CODE_SIGN_ENTITLEMENTS'] = "#{TARGET_NAME}/#{TARGET_NAME}.entitlements"
  settings['CODE_SIGN_STYLE'] = 'Automatic'
  settings['CURRENT_PROJECT_VERSION'] = '1'
  settings['GENERATE_INFOPLIST_FILE'] = 'YES'
  settings['INFOPLIST_FILE'] = "#{TARGET_NAME}/Info.plist"
  settings['INFOPLIST_KEY_CFBundleDisplayName'] = TARGET_NAME
  settings['INFOPLIST_KEY_NSHumanReadableCopyright'] = ''
  settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
  settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
  settings['MARKETING_VERSION'] = '1.0'
  settings['PRODUCT_BUNDLE_IDENTIFIER'] = widget_bundle_id
  settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
  settings['SKIP_INSTALL'] = 'YES'
  settings['SWIFT_EMIT_LOC_STRINGS'] = 'YES'
  settings['SWIFT_VERSION'] = '5.0'
  settings['TARGETED_DEVICE_FAMILY'] = '1,2'
  settings['ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME'] = 'AccentColor'
  settings['ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME'] = 'WidgetBackground'
end

debug_config = widget_target.build_configurations.find { |c| c.name == 'Debug' }
if debug_config
  debug_config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
  debug_config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
end

# Give Runner the same App Group entitlement so the host app and the widget
# extension can share data (via UserDefaults(suiteName:)). This only points
# Runner at the entitlements file that already sits at ios/Runner/ — it
# doesn't create the App Group in an Apple Developer account, which is a
# one-time manual step done outside this script.
runner_target.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end
runner_group = project.main_group['Runner']
runner_group.new_file('Runner.entitlements') if runner_group

# RunnerTests is a unit-test bundle hosted inside Runner.app (see TEST_HOST in
# its build settings), so it runs with Runner's App Group entitlement at
# runtime — no separate entitlement needed. Compile the widget's view code
# into it too (same file, added to a second target) so its snapshot test
# exercises the exact view VerseWidget renders, not a reimplementation.
runner_tests_target = project.targets.find { |t| t.name == 'RunnerTests' }
runner_tests_group = project.main_group['RunnerTests']
if runner_tests_target && runner_tests_group
  runner_tests_target.source_build_phase.add_file_reference(entry_view_ref)
  snapshot_test_ref = runner_tests_group.new_file(snapshot_test_file_name)
  runner_tests_target.source_build_phase.add_file_reference(snapshot_test_ref)
end

copy_phase = runner_target.new_copy_files_build_phase('Embed Foundation Extensions')
copy_phase.symbol_dst_subfolder_spec = :plug_ins
embed_build_file = copy_phase.add_file_reference(widget_target.product_reference)
embed_build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# new_copy_files_build_phase appends to the end of build_phases, landing this
# copy phase after "Thin Binary". Xcode's new build system always makes
# ProcessInfoPlistFile depend on any embedded extension's Info.plist, and
# that step runs as part of "Thin Binary". If "Thin Binary" is scheduled
# before this copy phase, Xcode reports "Cycle inside Runner": the copy
# waits on Thin Binary finishing, while Thin Binary (via ProcessInfoPlistFile)
# waits on the copy's output. Moving the copy phase to just before
# "Thin Binary" removes the first edge and breaks the cycle.
thin_binary_index = runner_target.build_phases.index { |phase| phase.respond_to?(:name) && phase.name == 'Thin Binary' }
if thin_binary_index
  runner_target.build_phases.delete(copy_phase)
  runner_target.build_phases.insert(thin_binary_index, copy_phase)
end

runner_target.add_dependency(widget_target)

project.save

puts "Added #{TARGET_NAME} target (bundle id #{widget_bundle_id}) and embedded it in Runner."
