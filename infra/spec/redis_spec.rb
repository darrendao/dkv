require 'spec_helper'

redis_name = 'rer12jxoysi8s321'
redis_shard_count = 2
redis_node_count = 2

(1..redis_shard_count).each do |shard_id|
  (1..redis_node_count).each do |node_id|
    shard_id = "%.4d" % shard_id
    node_id = "%.3d" % node_id

    describe elasticache("#{redis_name}-#{shard_id}-#{node_id}") do
      it { should exist }
      its(:engine_version) { should eq '3.2.4' }
      its(:engine) { should eq 'redis' }
      its(:cache_node_type) { should eq 'cache.t2.micro' }
    end

  end
end
