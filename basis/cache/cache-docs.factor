USING: accessors cache help.markup help.syntax math quotations system ;
IN: cache

HELP: timed-cache-assoc
{ $class-description "A disposable cache whose entries expire after an idle interval measured with a monotonic clock. The " { $slot "max-age" } " slot is an interval in nanoseconds. Reads refresh an entry's last-use time; " { $link purge-cache } " disposes entries whose idle interval has reached this limit. The " { $slot "clock" } " slot contains a quotation with stack effect " { $snippet "( -- ns )" } ", defaulting to " { $link nano-count } "." } ;

HELP: <timed-cache-assoc>
{ $values { "cache" timed-cache-assoc } }
{ $description "Creates a disposable cache with a ten-second idle timeout. Expiry depends on elapsed time, so repeated frame redraws do not prematurely evict cached objects." } ;
