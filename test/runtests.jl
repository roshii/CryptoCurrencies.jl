using Currencies
using Base.Test

# Get currencies for tests
@usingcurrencies USD, CAD, EUR, GBP, JPY
@usingcurrencies CNY

# Basic arithmetic
@test 1USD + 2USD == 3USD
@test 1.5USD * 3 == 4.5USD
@test 1.11USD * 999 == 1108.89USD
@test -1USD == -(1USD)
@test 1USD == one(USD)
@test 10USD / 1USD == 10.0
@test div(10USD, 3USD) == 3
@test rem(10USD, 3USD) == 1USD
@test one(Monetary{:USD}) == USD

# no mixing types
@test_throws ArgumentError 1USD + 1CAD
@test_throws ArgumentError 100JPY - 0USD  # even when zero!
@test_throws MethodError 1USD + 1
@test_throws MethodError 2 - 1JPY
@test_throws MethodError 1USD / 1CAD
@test_throws MethodError div(10USD, 5)    # meaningless
@test_throws MethodError 10USD % 5        # meaningless

# comparisons
@test 1EUR < 2EUR
@test 3JPY > 2JPY
@test 3JPY >= 3JPY
@test -1USD != 0USD
@test sort([0.5EUR, 0.7EUR, 0.3EUR]) == [0.3EUR, 0.5EUR, 0.7EUR]
@test currency(2GBP) == :GBP
@test currency(zero(Monetary{:CNY})) == :CNY

# investment
@test compoundfv(1000USD, 0.02, 12) == 1268.24USD
@test simplefv(1000USD, 0.04, 12) == 1480USD

# big int monetary
BI_USD = Monetary{:USD, BigInt}(100)
@test BigInt(2)^100 * BI_USD + 10BI_USD == (BigInt(2)^100 + 10) * BI_USD

# baskets
@test StaticBasket([100USD, 200USD]) == StaticBasket(300USD)
@test contains(string(StaticBasket([100USD, 200EUR])), "200.00 EUR")

basket_a = StaticBasket(100USD)
basket_b = StaticBasket(20EUR)
basket_c = basket_a + basket_b
basket_d = 4 * basket_c
basket_e = compoundfv(basket_c, 0.02, 12)
basket_f = basket_a - basket_b
basket_g = basket_f / 4

@test basket_c == StaticBasket([100USD, 20EUR])
@test basket_d == StaticBasket([400USD, 80EUR])
@test basket_e == StaticBasket([126.82USD, 25.36EUR])
@test basket_f == StaticBasket([100USD, -20EUR])
@test basket_g == StaticBasket([25USD, -5EUR])

# false positive tests for comparison
@test basket_c != StaticBasket()
@test basket_c != StaticBasket([100USD, 20EUR, 20GBP])
@test StaticBasket([100USD, 20EUR, 20GBP]) != basket_c

# mixed arithmetic
basket_h = basket_f + 20JPY
basket_i = basket_h - 100USD
basket_j = -20EUR - basket_i
basket_k = DynamicBasket() + basket_j

@test basket_h == StaticBasket([100USD, -20EUR, 20JPY])
@test basket_i == StaticBasket([-20EUR, 20JPY])
@test basket_j == -20JPY
@test basket_j == basket_k

# false positive tests for comparison
@test basket_i != -20EUR
@test basket_j != -20USD

# basket constructor & zero
basket_l = StaticBasket([basket_i, basket_j, 100JPY])
basket_m = zero(StaticBasket)
basket_n = zero(basket_l)
basket_o = zero(DynamicBasket)
@test basket_l == StaticBasket([-20EUR, 100JPY])
@test basket_m == basket_n == StaticBasket() == basket_o

# errors
@test_throws ArgumentError StaticBasket([1, 2, 3])
@test_throws ArgumentError DynamicBasket([1USD, (1USD, 2USD, 3)])

# iteration, access, & dynamic
@test isempty(collect(StaticBasket([100USD, -100USD])))
@test basket_g[:EUR] == -5EUR
basket_dyn = DynamicBasket() + basket_g
basket_dyn[:CAD] = 10CAD
@test basket_dyn == DynamicBasket([25USD, -5EUR, 10CAD])
@test haskey(basket_dyn, :USD)
@test !haskey(basket_dyn, :JPY)
push!(basket_dyn, 15JPY)
@test basket_dyn == DynamicBasket([25USD, -5EUR, 10CAD, 15JPY])
push!(basket_dyn, -10EUR)
@test basket_dyn == DynamicBasket([25USD, -15EUR, 10CAD, 15JPY])
push!(basket_dyn, -10CAD)
@test !haskey(basket_dyn, :CAD)  # zero keys should act invisible
@test length(collect(basket_dyn)) == 3

# errors
@test_throws AssertionError basket_dyn[:USD] = 100CAD

# manual control (from README)
money = 1USD
magn = int(money)
symb = currency(money)
a = π * magn
b = π * a
@test Monetary(symb, round(Int, b)) == 9.87USD

# decimals
@test int(100JPY) == 100
@test int(100USD) == 10000

# give change (from README)
COINS = [500EUR, 200EUR, 100EUR, 50EUR, 20EUR, 10EUR, 5EUR, 2EUR, 1EUR, 0.5EUR,
    0.2EUR, 0.1EUR, 0.05EUR, 0.02EUR, 0.01EUR]
function change(amount::Monetary{:EUR,Int})
    coins = Dict{Monetary{:EUR,Int}, Int}()
    for denomination in COINS
        coins[denomination], amount = divrem(amount, denomination)
    end
    coins
end

sum([k*v for (k, v) in change(167.25EUR)])  # 167.25EUR

# Display
@test contains(string(1USD), "1.00")
@test contains(string(1JPY), "1")
@test contains(string(StaticBasket([1USD, 1CAD])), "CAD")
@test contains(string(DynamicBasket([1USD, 1CAD])), "USD")
@test !contains(string(StaticBasket([1USD, 1CAD, -1CAD])), "CAD")

# Custom currencies
@usingcustomcurrency xbt "Bitcoin (100 satoshi unit)" 2

@test contains(string(10xbt), "xbt")
@test contains(string(10xbt), "10.00")
@test 10xbt - 5xbt == 5xbt
@test StaticBasket([10xbt, 10USD]) - 10USD == 10xbt

custom = newcurrency!(:custom, "Custom Currency", 6)

@test contains(string(custom), "1.000000")
@test contains(string(custom), "custom")
@test 10custom / 10000000 == 0.000001custom

@test currencyinfo(:USD) == "United States dollar"
@test currencyinfo(:custom) == "Custom Currency"
@test currencyinfo(10custom) == "Custom Currency"
@test currencyinfo(Monetary{:xbt}) == "Bitcoin (100 satoshi unit)"