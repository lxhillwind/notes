% crypto reading notes

# 20221029_225657 otp (Shannon cipher)

E(k, m) -> c; D(k, c) -> m.

four types (variants):

- K, M, C is same length; k xor m => c;
- K is longer than M==C;
- (substitution;) K is permutation (space is `M!`); (TODO: check this)
m xor k[i] => c; (k[i]: i'th permutation)
c xor [?-i] => m.
- m + k mod n => c; (TODO: where is n?)

perfect security: Pr[E(k, m1) == c] == Pr[E(k, m2) == c]

# 20221030_111825 perfect security, continue

- theorem 2.1: three assertions about perfect security are equal. TODO: which three?

TODO: why substitution otp, while looks more complex, is not perfect secure?
(see example 2.6)

- theorem 2.3: what is `predicate`? (seems like probability word... ok, it's
  defined right above this def)

- Pr[m=m | c=c] = Pr[m=m]: (conditional probability) knows c does not impact
  m (cyphertext reveals nothing about message).
- Pr[c=c | m=m] = Pr[c=c]: choosing message does not impact cyphertext
  distribution.
