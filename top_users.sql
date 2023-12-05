WITH dictionary AS (
  SELECT
    ARRAY_CONSTRUCT(
      'ImmutableX',
      '0x5fdcca53617f4d2b9134b29090c87d01058e27e9',
      'https://immutable.com/',
      'https://etherscan.io/address/0x5fdcca53617f4d2b9134b29090c87d01058e27e9'
    ) AS imx,
    ARRAY_CONSTRUCT(
      'Sorare',
      '0xf5c9f957705bea56a7e806943f98f7777b995826',
      'https://sorare.com/',
      'https://etherscan.io/address/0xf5c9f957705bea56a7e806943f98f7777b995826'
    ) AS sorare,
    ARRAY_CONSTRUCT(
      'dYdX', -- Perpetual Exchange
      '0xd54f502e184b6b739d7d27a6410a67dc462d69c8',
      'https://dydx.exchange/',
      'https://etherscan.io/address/0xd54f502e184b6b739d7d27a6410a67dc462d69c8'
    ) AS dydx,
    ARRAY_CONSTRUCT(
      'RhinoFi',
      '0x5d22045daceab03b158031ecb7d9d06fad24609b',
      'https://rhino.fi/',
      'https://etherscan.io/address/0x5d22045daceab03b158031ecb7d9d06fad24609b'
    ) AS rhino,
    ARRAY_CONSTRUCT(
      'Myria',
      '0x3071be11f9e92a9eb28f305e1fa033cd102714e7',
      'https://myria.com/',
      'https://etherscan.io/address/0x3071be11f9e92a9eb28f305e1fa033cd102714e7'
    ) AS myria,
    ARRAY_CONSTRUCT(
      'Apex', -- Perpetual Exchange
      '0xa1d5443f2fb80a5a55ac804c948b45ce4c52dcbb',
      'https://apex.exchange/',
      'https://etherscan.io/address/0xa1d5443f2fb80a5a55ac804c948b45ce4c52dcbb'
    ) AS apex,
    ARRAY_CONSTRUCT(
      'Reddio',
      '0xb62bcd40a24985f560b5a9745d478791d8f1945c',
      'https://reddio.com/',
      'https://etherscan.io/address/0xb62bcd40a24985f560b5a9745d478791d8f1945c'
    ) AS reddio
), rainbow AS(
  SELECT
    IMX[0] AS name,
    IMX[1] AS address,
    IMX[2] AS website,
    IMX[3] AS contract
  FROM (
    SELECT imx FROM dictionary
    UNION
    SELECT sorare FROM dictionary
    UNION
    SELECT dydx FROM dictionary
    UNION
    SELECT rhino FROM dictionary
    UNION
    SELECT myria FROM dictionary
    UNION
    SELECT apex FROM dictionary
    UNION
    SELECT reddio FROM dictionary
  )
)


SELECT
  main.FROM_ADDRESS,
  COUNT(DISTINCT(TO_ADDRESS)) AS cnt
FROM ethereum.core.fact_transactions main
JOIN rainbow r
ON main.TO_ADDRESS = r.address
GROUP BY FROM_ADDRESS
ORDER BY cnt DESC
LIMIT 10000
