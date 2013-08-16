
require 'test/unit'
require 'elbping/resolver.rb'

DEFAULT_NS = ENV['TEST_NS'] || 'ns-941.amazon.com'
DEFAULT_GOOD_ELB = ENV['TEST_GOOD_ELB'] || 'test-elb-868888812.us-east-1.elb.amazonaws.com' # feels dirty

class TestResolver< Test::Unit::TestCase
  def test_resolve_ns_ips
    # IPs should always return as-is but within a list
    ns_ips = ["1.1.1.1", "127.0.0.1", "255.255.255.255", "192.168.0.1", "4.2.2.1"]
    ns_ips.each { |input|
      output = nil
      assert_nothing_raised do
        output = ElbPing::Resolver.resolve_ns input
      end
      assert_equal [input], output
    }
  end

  def test_resolve_ns_badips
    # Kind of sucks, will probablt result in DNS errors
    bad_ns_ips = [".1.1.1.1", "256.256.256.256"]
    bad_ns_ips.each { |input|
      output = nil
      output = ElbPing::Resolver.resolve_ns input
      assert_not_equal [input], output
    }
  end

  def test_resolve_ns_hosts
    hosts = { "google-public-dns-a.google.com" => "8.8.8.8",
              "google-public-dns-b.google.com" => "8.8.4.4"}

    hosts.each { |host, expected_ip|
      resolved_ip = ElbPing::Resolver.resolve_ns host
      assert_equal [expected_ip], resolved_ip
    }
  end

  def test_bad_queries
    ["fake.amazonaws.com", "google.com", "nxdomain.asdf"].each { |tgt|
      assert_raise RuntimeError do
        ElbPing::Resolver.find_elb_nodes(tgt, DEFAULT_NS)
      end
    }
  end

  def test_good_query
    resp = nil
    assert_nothing_raised do
      resp = ElbPing::Resolver.find_elb_nodes(DEFAULT_GOOD_ELB, DEFAULT_NS)
    end
    # I don't actually care what the results are, only that they are a list
    assert_equal resp.class, Array
  end
end
