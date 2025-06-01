defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  setup do
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert KV.Registry.lookup(registry, "shopping") == :error
  end

  # Whenever a registry process crashes,
  # supervisor's job is to replaces the process with new one.
  #
  # Whenever a bucket crashes, it'll also automatically
  # crashes the registry because of start_link
  #
  # So one bucket crash, kills the entire registry process
  # and all the other buckets associated with it.
  #
  # To prevent this, we need to use DynamicSupervisor
  # instead of start_link.
  #
  # DynamicSupervisor supervisor creates supervised child process
  # on runtime.
  #
  # It can be also added to Supervisor tree, so our old supervisor
  # can also supervise the children of dynamic supervisor
  #
  # With the help of DynamicSupervisor, if a bucket crashes,
  # it'll not crash the registry and the bucket process will get
  # replaced by a new bucket process.
  #
  # If you don't want to new bucket process during crash, we can make
  # bucket startup strategy as :temporary. f they crash, regardless of
  # the reason, they should not be restarted.
  #
  # Note: Child supervisor can have its own restart strategy than
  # the parent supervisor
  test "removes bucket on crash", %{registry: registry} do
    KV.Registry.create(registry, "shopping")
    KV.Registry.create(registry, "fishing")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
    {:ok, fish_bucket} = KV.Registry.lookup(registry, "fishing")

    # Stop the bucket with non-normal reason
    Agent.stop(bucket, :shutdown)
    assert KV.Registry.lookup(registry, "shopping") == :error
    assert KV.Registry.lookup(registry, "fishing") == {:ok, fish_bucket}
  end
end
