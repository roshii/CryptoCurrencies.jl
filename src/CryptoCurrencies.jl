module CryptoCurrencies

# Data obtained from https://datahub.io/core/country-codes
# Consider downloading data in build.jl?

using DelimitedFiles

export CryptoCurrency

const (data,headers) = readdlm(joinpath(@__DIR__,"data","raw.csv"),',',header=true)

struct CryptoCurrency{T}
    function CryptoCurrency{T}() where T
        c = new()
        list[T] = c
        return c
    end
end
const list = Dict{Symbol,CryptoCurrency}()

const (nrow,ncol) = size(data)
for i in 1:nrow
    currencies = split(data[i,1],",")
    currency_units = split(string(data[i,2]),",")
    currency_names = split(data[i,3],",")
    for (currency,currency_unit,currency_name) in zip(currencies,currency_units,currency_names)
        if (length(currency) == 3) & !isdefined(CryptoCurrencies,Symbol(currency))
            @eval CryptoCurrencies begin
                $(Symbol(currency)) = CryptoCurrency{Symbol($(currency))}()
                unit(::CryptoCurrency{Symbol($(currency))}) = parse(Int,$(currency_unit))
                name(::CryptoCurrency{Symbol($(currency))}) = $(currency_name)
                Base.show(io::Base.IO,::CryptoCurrency{Symbol($(currency))}) = print(io,$(currency))
            end
        end
    end
end

end
