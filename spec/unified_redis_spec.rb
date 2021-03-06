# encoding: utf-8
require 'spec_helper'

shared_examples "unified_redis" do

  it "should be able to get/set" do
    count = 0
    @r.del("chuck") do
      @r.get("chuck") do |value|
        value.should == nil
        @r.set("chuck", "norris") do
          @r.get("chuck") do |value|
            value.should == 'norris'
            count += 1
            EM.stop if EM.reactor_running?
          end
        end
      end
    end
    count.should == 1 unless EM.reactor_running?
  end

  it "should be able to use mget" do
    count = 0
    @r.mget("plop", "plip") do |values|
      values.should == [nil, nil]
      count += 1
      EM.stop if EM.reactor_running?
    end
    count.should == 1 unless EM.reactor_running?
  end
end


describe UnifiedRedis do
  context "with redis-rb" do
    before do
      @r = UnifiedRedis.new(Redis.new)
    end

    it_should_behave_like "unified_redis"
  end


  context "with em-redis" do
    around(:each) do |example|
      EM.run do
        redis = EM::Protocols::Redis.connect
        redis.errback do |code|
          puts "redis error"
        end
        @r = UnifiedRedis.new(redis)
        example.call
      end
    end

    it_should_behave_like "unified_redis"
  end
end
