defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end

  test "deletes values by key", %{bucket: bucket} do
    KV.Bucket.put(bucket, "milk", 10)
    assert KV.Bucket.get(bucket, "milk") == 10

    KV.Bucket.delete(bucket, "milk")
    assert KV.Bucket.get(bucket, "milk") == nil
  end

  test "return the deleted value", %{bucket: bucket} do
    KV.Bucket.put(bucket, "milk", 10)
    assert KV.Bucket.get(bucket, "milk") == 10

    assert KV.Bucket.delete(bucket, "milk") == 10
  end
end
