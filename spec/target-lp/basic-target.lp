\* Problem: Home heating *\

Minimize
 obj: + resistiveheater + 5 gasboiler + 10 gas + 10 electricity

Subject To
 heat: + 0.9 gasboiler + resistiveheater = 300
 gas: + gas - gasboiler = 0
 electricity: + electricity - resistiveheater = 0

Bounds
 0 <= gas <= 10000
 0 <= electricity <= 100

End
