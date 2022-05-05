include("src/main.jl")

if !isdefined(Base, :active_repl)
    main(ARGS)
end

function julia_main()::Cint
    return main(ARGS)
end
