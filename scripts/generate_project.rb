require "xcodeproj"

root = File.expand_path("..", __dir__)
project_path = File.join(root, "TabekiriBiyori.xcodeproj")
FileUtils.rm_rf(project_path)
project = Xcodeproj::Project.new(project_path)

app = project.new_target(:application, "TabekiriBiyori", :ios, "17.0")
widget = project.new_target(:app_extension, "TabekiriWidget", :ios, "17.0")
tests = project.new_target(:unit_test_bundle, "TabekiriBiyoriTests", :ios, "17.0")
ui_tests = project.new_target(:ui_test_bundle, "TabekiriBiyoriUITests", :ios, "17.0")
tests.add_dependency(app)
ui_tests.add_dependency(app)
app.add_dependency(widget)

main_group = project.main_group.new_group("TabekiriBiyori", "TabekiriBiyori")
widget_group = project.main_group.new_group("TabekiriWidget", "TabekiriWidget")
test_group = project.main_group.new_group("TabekiriBiyoriTests", "TabekiriBiyoriTests")
ui_test_group = project.main_group.new_group("TabekiriBiyoriUITests", "TabekiriBiyoriUITests")

app_sources = Dir.glob(File.join(root, "TabekiriBiyori", "**", "*.swift"))
app_sources.each do |path|
  ref = main_group.new_file(path.delete_prefix(File.join(root, "TabekiriBiyori") + "/"))
  app.source_build_phase.add_file_reference(ref)
end

widget_sources = [
  "TabekiriWidget/TabekiriWidget.swift",
  "TabekiriBiyori/App/AppTheme.swift",
  "TabekiriBiyori/Models/FoodItem.swift",
  "TabekiriBiyori/Services/WidgetSnapshotService.swift"
]
widget_sources.each do |relative|
  ref = widget_group.new_file(File.join(root, relative))
  widget.source_build_phase.add_file_reference(ref)
end

Dir.glob(File.join(root, "TabekiriBiyoriTests", "*.swift")).each do |path|
  ref = test_group.new_file(File.basename(path))
  tests.source_build_phase.add_file_reference(ref)
end

Dir.glob(File.join(root, "TabekiriBiyoriUITests", "*.swift")).each do |path|
  ref = ui_test_group.new_file(File.basename(path))
  ui_tests.source_build_phase.add_file_reference(ref)
end

assets = main_group.new_file("Assets.xcassets")
app.resources_build_phase.add_file_reference(assets)

["Localizable.strings", "InfoPlist.strings"].each do |filename|
  variant = main_group.new_variant_group(filename)
  ["ja", "en", "zh-Hans"].each do |locale|
    ref = variant.new_file("#{locale}.lproj/#{filename}")
    ref.name = locale
  end
  app.resources_build_phase.add_file_reference(variant)
end

widget_strings = main_group.new_variant_group("Widget.strings")
["ja", "en", "zh-Hans"].each do |locale|
  ref = widget_strings.new_file("#{locale}.lproj/Widget.strings")
  ref.name = locale
end
widget.resources_build_phase.add_file_reference(widget_strings)

embed = app.new_copy_files_build_phase("Embed App Extensions")
embed.symbol_dst_subfolder_spec = :plug_ins
embed.add_file_reference(widget.product_reference, true)

project.root_object.known_regions = ["en", "ja", "zh-Hans", "Base"]
project.root_object.development_region = "en"

app.build_configurations.each do |config|
  config.build_settings.merge!(
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.zhouyajie.tabekiribiyori",
    "MARKETING_VERSION" => "1.0.0",
    "CURRENT_PROJECT_VERSION" => "1",
    "INFOPLIST_FILE" => "TabekiriBiyori/Info.plist",
    "CODE_SIGN_ENTITLEMENTS" => "TabekiriBiyori/TabekiriBiyori.entitlements",
    "ASSETCATALOG_COMPILER_APPICON_NAME" => "AppIcon",
    "TARGETED_DEVICE_FAMILY" => "1",
    "SUPPORTS_MACCATALYST" => "NO",
    "SUPPORTS_XR_DESIGNED_FOR_IPHONE_IPAD" => "NO",
    "SWIFT_VERSION" => "5.0",
    "GENERATE_INFOPLIST_FILE" => "NO"
  )
end

widget.build_configurations.each do |config|
  config.build_settings.merge!(
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.zhouyajie.tabekiribiyori.widget",
    "MARKETING_VERSION" => "1.0.0",
    "CURRENT_PROJECT_VERSION" => "1",
    "INFOPLIST_FILE" => "TabekiriWidget/Info.plist",
    "CODE_SIGN_ENTITLEMENTS" => "TabekiriWidget/TabekiriWidget.entitlements",
    "TARGETED_DEVICE_FAMILY" => "1",
    "SWIFT_VERSION" => "5.0",
    "GENERATE_INFOPLIST_FILE" => "NO",
    "SKIP_INSTALL" => "YES"
  )
end

tests.build_configurations.each do |config|
  config.build_settings.merge!(
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.zhouyajie.tabekiribiyori.tests",
    "GENERATE_INFOPLIST_FILE" => "YES",
    "TARGETED_DEVICE_FAMILY" => "1",
    "SWIFT_VERSION" => "5.0",
    "TEST_HOST" => "$(BUILT_PRODUCTS_DIR)/TabekiriBiyori.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/TabekiriBiyori",
    "BUNDLE_LOADER" => "$(TEST_HOST)"
  )
end

ui_tests.build_configurations.each do |config|
  config.build_settings.merge!(
    "PRODUCT_BUNDLE_IDENTIFIER" => "com.zhouyajie.tabekiribiyori.uitests",
    "GENERATE_INFOPLIST_FILE" => "YES",
    "TARGETED_DEVICE_FAMILY" => "1",
    "SWIFT_VERSION" => "5.0",
    "TEST_TARGET_NAME" => "TabekiriBiyori"
  )
end

scheme = Xcodeproj::XCScheme.new
scheme.add_build_target(app)
scheme.add_build_target(widget)
scheme.set_launch_target(app)
scheme.add_test_target(tests)
scheme.add_test_target(ui_tests)
scheme.save_as(project_path, "TabekiriBiyori", true)

project.save
