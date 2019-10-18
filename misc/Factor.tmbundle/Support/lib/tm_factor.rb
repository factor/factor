require 'osx/cocoa'

def _wait_for_return_value(pb)
    origCount = pb.changeCount
    sleep 0.125 while pb.changeCount == origCount
end

def perform_service(service, in_string, wait_for_return_value=false)
    p = OSX::NSPasteboard.pasteboardWithUniqueName
    p.declareTypes_owner([OSX::NSStringPboardType], nil)
    p.setString_forType(in_string, OSX::NSStringPboardType)
    raise "Unable to call service #{service}" unless OSX::NSPerformService(service, p)
    _wait_for_return_value(p) if wait_for_return_value
    p.stringForType(OSX::NSStringPboardType)
end

def textmate_front()
    system %Q{osascript -e 'tell app "TextMate" to activate'};
end

def factor_run(code)
    perform_service("Factor/Evaluate in Listener", code)
end

def factor_eval(code)
    r = perform_service("Factor/Evaluate Selection", code, true)
    textmate_front
    r
end

def doc_using_statements(document)
    document.scan(/\b(USING:\s[^;]*\s;|USE:\s+\S+|IN:\s\S+)/).join("\n") << "\n"
end

def doc_vocab(document) 
  document.sub(/\bIN:\s(\S+)/, %Q("\\1"))
end

def line_current_word(line, point)
    left = line.rindex(/\s/, point - 1) || 0; right = line.index(/\s/, point) || line.length
    line[left..right]
end
