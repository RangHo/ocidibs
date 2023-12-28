#!/usr/bin/env ruby
# frozen_string_literal: true

# Install required gems using bundler
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'oci', require: 'oci'
end

require 'json'
require 'securerandom'
require 'optparse'

# Parameters required to create a functional instance
# If they have some value, then that is the sensible default
instance = OCI::Core::Models::LaunchInstanceDetails.new
instance.availability_domain = nil
instance.compartment_id = nil
instance.display_name = SecureRandom.hex 8 # make random name
instance.image_id = nil
instance.shape = 'VM.Standard.A1.Flex'
instance.shape_config = OCI::Core::Models::LaunchInstanceShapeConfigDetails.new
instance.shape_config.ocpus = 4
instance.shape_config.memory_in_gbs = 24
instance.create_vnic_details = OCI::Core::Models::CreateVnicDetails.new
instance.create_vnic_details.subnet_id = nil
instance.metadata = {
  'ssh_authorized_keys' => ''
}

dry_run = false
retry_interval = nil

OptionParser.new do |opts|
  opts.banner = 'Usage: ocidibs.rb [options]'

  opts.on('--request JSON', 'The raw JSON request payload from the web console.') do |content|
    json_content = JSON.parse(content)
    instance.availability_domain = json_content['availabilityDomain']
    instance.compartment_id = json_content['compartmentId']
    instance.display_name = json_content['displayName']
    instance.image_id = json_content['sourceDetails']['imageId']
    instance.shape = json_content['shape']
    instance.shape_config.ocpus = json_content['shapeConfig']['ocpus']
    instance.shape_config.memory_in_gbs = json_content['shapeConfig']['memoryInGBs']
    instance.create_vnic_details.subnet_id = json_content['createVnicDetails']['subnetId']
    instance.metadata['ssh_authorized_keys'] = json_content['metadata']['ssh_authorized_keys']
  end

  opts.on('--availability-domain DOMAIN', 'The ID of the Availability Domain of the region.') do |ad|
    instance.availability_domain = ad
  end

  opts.on('--compartment-id COMPARTMENT', 'The compartment ID of the instance.') do |compartment|
    instance.compartment_id = compartment
  end

  opts.on('--display-name NAME', 'The name of your instance. A random name will be created if none specified.') do |name|
    instance.display_name = name
  end

  opts.on('--image-id ID', 'The OCID of the image to use.') do |id|
    instance.image_id = id
  end

  opts.on('--shape SHAPE', 'The shape of the instance. Default is VM.Standard.A1.Flex.') do |shape|
    instance.shape = shape
  end

  opts.on('--ocpus COUNT', Float, 'Number of OCPU cores. Default is 4.') do |count|
    instance.shape_config.ocpus = count
  end

  opts.on('--memory-in-gbs SIZE', Float, 'Size of the RAM, in GBs. Default is 24.') do |size|
    instance.shape_config.memory_in_gbs = size
  end

  opts.on('--subnet-id ID', 'The OCID of the subnet to use. You may need to create a subnet first.') do |id|
    instance.create_vnic_details.subnet_id = id
  end

  opts.on('--ssh-public-key KEYFILE', 'The SSH public key file to use when connecting to the new instance.') do |keyfile|
    instance.metadata['ssh_authorized_keys'] = File.read(keyfile)
  end

  opts.on('--dry-run', 'Don\'t actually send a request to Oracle Cloud.') do
    dry_run = true
  end

  opts.on('--retry SECONDS', Integer, 'Automatically retry the same request') do |sec|
    retry_interval = sec
  end
end.parse!

puts 'This script will fire up an instance with the following settings:'
puts instance

puts '-' * 16
puts 'Sending request now!'

unless dry_run
  is_complete = retry_interval.nil?
  loop do
    before_time = Time.now

    puts "[#{before_time.strftime '%F %R'}] Sending a request..."

    begin
      api = OCI::Core::ComputeClient.new
      api.launch_instance instance
      puts 'Successfully created an instance!'

      unless is_complete
        puts 'Now this program will be terminated...'
        is_complete = true
      end
    rescue OCI::Errors::ServiceError => e
      puts "[#{Time.now.strftime '%F %R'}] The request failed with an error: #{e.message}"
    end

    break if is_complete

    wait_interval = retry_interval - (Time.now - before_time)
    sleep(wait_interval) if wait_interval.positive?
  end
end
