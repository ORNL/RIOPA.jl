import RIOPA

function julia_main()::Cint
    return RIOPA.main(ARGS)
end

if !isdefined(Base, :active_repl)
    julia_main()
end
