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
      'RhinoFi/DeversiFi',
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
), result AS (
  SELECT
    r.name AS application,
    main.BLOCK_TIMESTAMP AS interacted_on,
    main.TX_HASH AS hash,
    ROW_NUMBER() OVER(ORDER BY interacted_on DESC) AS early_bird_score
  FROM ethereum.core.fact_transactions main
  JOIN rainbow r
  ON main.TO_ADDRESS = r.address
  WHERE main.FROM_ADDRESS = LOWER('{{Address}}')
  AND BLOCK_TIMESTAMP > '2020-05-01'
  ORDER BY interacted_on
), txns AS (
  SELECT 
      application,
      MIN(interacted_on) AS first_transaction
  FROM result
  GROUP BY application
), first_txns AS (
  SELECT 
    f.application,
    f.first_transaction,
    r.hash AS hash
  FROM txns f
  LEFT JOIN result r ON f.application = r.application AND f.first_transaction = r.interacted_on
)

SELECT
  r.name,
  CASE
    WHEN f.first_transaction <= '2022-06-01' THEN '✅ YES'
    ELSE '❌ NO'
  END AS used_before_june_2022,
  CASE
    WHEN f.hash IS NULL THEN 'Never Used!'
    ELSE LEFT(f.hash, 6) || '***' || RIGHT(f.hash, 4)
  END AS first_txn_hash,
  r.website,
  CASE
    WHEN f.first_transaction IS NULL THEN 'Never Used!'
    ELSE TO_VARCHAR(f.first_transaction, 'YYYY-MM-DD @ HH24:MI')
  END AS first_interaction_date
FROM rainbow r
LEFT JOIN first_txns f
ON r.name = f.application
ORDER BY f.first_transaction