require "spec_helper"
require "bosh/gen/models"

class DeploymentManifestSpec < MiniTest::Spec
  it "creates manifest document with 2 jobs, no disk" do
    manifest = Bosh::Gen::Models::DeploymentManifest.new("myproj", "UUID", 
      {"name" => "myrelease", "version" => 2},
      {"instance_type" => "m1.small"})
    manifest.jobs = [
      { "name" => "job-with-ips",  "static_ips" => ['1.2.3.4']},
      { "name" => "misc"}
    ]
    manifest.to_yaml.must_equal fixture_manifest("2_jobs_1_ip_no_disk")
  end

  it "creates manifest document with 2 jobs, with disk" do
    manifest = Bosh::Gen::Models::DeploymentManifest.new("myproj", "UUID", 
      {"name" => "myrelease", "version" => 2},
      {"instance_type" => "m1.small", "persistent_disk" => "8196"})
    manifest.jobs = [
      { "name" => "job-with-ips",  "static_ips" => ['1.2.3.4']},
      { "name" => "misc"}
    ]
    manifest.to_yaml.must_equal fixture_manifest("2_jobs_1_ip_8196_disk")
  end
  
  def fixture_manifest(name)
    File.read(File.expand_path("../../fixtures/deployment_manifests/#{name}.yml", __FILE__))
  end
end
