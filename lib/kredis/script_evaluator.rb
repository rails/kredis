module Kredis::ScriptEvaluator
  class UnfrozenScriptError < StandardError; end

  SCRIPT_DIGESTS = Hash.new do |hash, script|
    raise UnfrozenScriptError unless script.frozen?

    hash[script] = -Digest::SHA1.hexdigest(script)
  end

  extend self

  def eval(redis, script, **kwargs)
    redis.evalsha(SCRIPT_DIGESTS[script], **kwargs)
  rescue Redis::CommandError
    redis.eval(script, **kwargs)
  end
end
