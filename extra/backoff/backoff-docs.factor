USING: backoff help.markup help.syntax kernel math quotations ;
IN: backoff

HELP: backoff-delay
{ $values { "attempt" integer } { "policy" "a delay policy" } { "milliseconds" real } }
{ $description "Computes a delay for a zero-based attempt without changing the policy. Define a method on this generic to add another policy." }
{ $notes "Attempts must be nonnegative integers. Policy timings must be finite, nonnegative milliseconds. Linear steps must be nonnegative and exponential factors must be finite and at least one. Constructors store these caller-supplied values without validation." } ;

HELP: <constant-backoff>
{ $values { "delay" real } { "constant-backoff" constant-backoff } }
{ $description "Creates a policy that always returns the supplied delay in milliseconds." } ;

HELP: <linear-backoff>
{ $values { "min" real } { "max" real } { "step" real } { "linear-backoff" linear-backoff } }
{ $description "Creates a policy computing min + attempt * step, capped at max, in milliseconds. If min exceeds max the result is max." } ;

HELP: <exponential-backoff>
{ $values { "min" real } { "max" real } { "factor" real } { "jitter?" boolean } { "exponential-backoff" exponential-backoff } }
{ $description "Creates an exponential policy in milliseconds, capped at max. A zero minimum produces zero delays. If min exceeds max the result is max. With jitter, samples uniformly between min (or max if smaller) and the capped delay. Unlike the referenced Go implementation, jitter is applied after capping, so it remains useful at the cap." } ;

HELP: <default-backoff>
{ $values { "policy" exponential-backoff } }
{ $description "Creates an exponential policy starting at 100 milliseconds, doubling to a 10 second cap, without jitter." } ;

HELP: <backoff>
{ $values { "policy" "a delay policy" } { "backoff" backoff } }
{ $description "Creates a mutable counter starting at attempt zero. Independent counters may share a policy. Use a separate counter per retry loop; counters are not synchronized." } ;

HELP: next-backoff
{ $values { "backoff" backoff } { "milliseconds" real } }
{ $description "Returns the current attempt's delay and increments the counter. Does not sleep." } ;

HELP: reset-backoff
{ $values { "backoff" backoff } }
{ $description "Resets a counter to attempt zero." } ;

HELP: retry-backoff-with
{ $values { "quot" quotation } { "retry?" quotation } { "wait" quotation } { "policy" "a delay policy" } { "retries" integer } { "result" object } }
{ $description "Calls quot immediately, returning its single result on success (including f). On an exception, calls retry? with the error. If it returns true and retries remain, computes a delay, calls wait with milliseconds, and tries again. Otherwise rethrows the original error. A retry count of zero permits only the initial call. Each invocation owns a fresh counter. Exceptions from retry? or wait propagate." }
{ $notes "The operation has stack effect ( -- result ), the predicate ( error -- ? ), and wait ( milliseconds -- ). Capture inputs in a quotation; pack multiple outputs in an array. Only thrown errors trigger retries. External side effects are not rolled back. Choose a predicate appropriate to the operation and retry only operations whose repetition is acceptable." } ;

HELP: retry-backoff
{ $values { "quot" quotation } { "policy" "a delay policy" } { "retries" integer } { "result" object } }
{ $description "Retries any thrown error using the policy and the standard thread sleep. See retry-backoff-with for selective error handling or custom scheduling." }
{ $examples
    { $code "USING: backoff http.client ;"
        "[ \"https://example.com\" http-get nip ]"
        "<default-backoff> 3 retry-backoff" }
} ;

HELP: invalid-retry-count
{ $values { "count" object } }
{ $description "Thrown when a retry count is not a nonnegative integer." } ;

ARTICLE: "backoff" "Backoff policies and retries"
"Delay generation is independent of operations and sleeping, so the same policies can drive function retries, network reconnections, or a caller's own scheduler."
{ $subsections backoff-delay <constant-backoff> <linear-backoff> <exponential-backoff> <default-backoff> }
"For caller-managed state, use a counter or supply the attempt explicitly:"
{ $subsections <backoff> next-backoff reset-backoff }
"For operations returning one result:"
{ $subsections retry-backoff retry-backoff-with }
{ $url "https://github.com/jpillora/backoff/blob/master/backoff.go" } ;

ABOUT: "backoff"
