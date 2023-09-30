# VaxCounselors.jl

[![code style blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)

`VaxCounselors` is a envy-free based model for vaccines distribution.

----

This is a model developed for a Master's Project at Universidade de São Paulo (University
of São Paulo). It simulates the distribution of vaccines for a population of individuals in
a pandemic context using an Envy-Free strategy. Other strategies (Maximize-Benefit,
Minimize-Benefit, Oldest-First and Random-Vaccination) were also implemented for comparison
purposes.

## Quickstart

To install VaxCounselors.jl run

```julia
julia> ]
(my_project) pkg> add <path-to-package>
```

And to run all strategies for a country and some setups:

```julia-repl
julia> using VaxCounselors

julia> countries::Vector{String} = ["usa"]
julia> setups::Vector{Int64} = [1,2,3,4]

julia> VaxCounselors.run_model(countries, setups)
```


## Multithreading and Multiprocessing

To start julia enabling multithreading and multiple cores the flags `--threads` and
`--procs` can be used .

```bash
$ julia --project=./ --threads=auto --procs=6
```

More info on that can be found in Julia's
[multithread page](https://docs.julialang.org/en/v1/manual/multi-threading/#) and
[multi-processing page](https://docs.julialang.org/en/v1/manual/distributed-computing/).
