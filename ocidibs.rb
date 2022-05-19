#!/usr/bin/env ruby
# frozen_string_literal: true

# Install required gems using bundler
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'oci', require: 'oci'
end

if __FILE__ == $PROGRAM_NAME
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

  OptionParser.new do |opts|
    opts.banner = 'Usage: ocidibs.rb [options]'

    opts.on('--availability-domain DOMAIN') do |ad|
      instance.availability_domain = ad
    end

    opts.on('--compartment-id COMPARTMENT') do |compartment|
      instance.compartment_id = compartment
    end

    opts.on('--display-name NAME') do |name|
      instance.display_name = name
    end

    opts.on('--image-id ID') do |id|
      instance.image_id = id
    end

    opts.on('--shape SHAPE') do |shape|
      instance.shape = shape
    end

    opts.on('--ocpus COUNT', Float) do |count|
      instance.shape_config.ocpus = count
    end

    opts.on('--memory-in-gbs SIZE', Float) do |size|
      instance.shape_config.memory_in_gbs = size
    end

    opts.on('--subnet-id ID') do |id|
      instance.create_vnic_details.subnet_id = id
    end

    opts.on('--ssh-public-key KEYFILE') do |keyfile|
      instance.metadata['ssh_authorized_keys'] = File.read(keyfile)
    end

    opts.on('--dry-run') do
      dry_run = true
    end
  end.parse!

  puts 'This script will fire up an instance with the following settings:'
  puts instance.to_s

  if not dry_run
    error_message = ''
    begin
      api = OCI::Core::ComputeClient.new
      result = api.launch_instance instance
      puts "Successfully created an instance!"
    rescue OCI::Errors::ServiceError => error
      puts "The request failed with an error: #{error.message}"
      error_message = error.message
    end
  end
end
