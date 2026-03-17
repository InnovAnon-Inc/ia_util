-- ia_util/coros.lua

function ia_util.coro_sleep(seconds)
    local elapsed = 0
    while elapsed < seconds do
        -- Capture dtime from the resume call
        local _, dtime = coroutine.yield()
        elapsed = elapsed + (dtime or 0.1) -- Fallback if dtime is nil
    end
end
