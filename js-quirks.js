/* JavaScript has some quirks */

/* Octoganal type fallback (0-7) instead of Decimal (0-9) when prepending 0. I.. We should use 0o15 instead to force octogonal instead of guessing */
console.log(018 - 015)


{} == '[object Object]' // true: returns true as The default conversion from an object to string is "[object Object]".

false == '0' // true: this is because false will be coerced to number, '0' will also be coerced into number 0 == 0