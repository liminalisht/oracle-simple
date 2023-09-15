{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
module Main where

import Data.Text (Text)
import Database.Oracle.Simple
import GHC.Generics (Generic)

main :: IO ()
main = do
  let stmt = "select count(*), sysdate, 'text goes here', 125.24, TO_BINARY_FLOAT ('3.14'), CAST(null AS NUMBER(10,2)) from dual"
  conn <- createConn (ConnectionParams "username" "password" "localhost/XEPDB1")
  rows <- query @ReturnedRow conn (stmt <> " UNION ALL " <> stmt)
  mapM_ print rows

newtype RowCount = RowCount { getRowCount :: Double }
  deriving stock (Show)
  deriving newtype (FromField)

data ReturnedRow = ReturnedRow
  { count :: RowCount
  , sysdate :: DPITimeStamp
  , message :: Maybe String
  , amount :: Double
  , piValue :: Float
  , nullValue :: Maybe Double
  }
  deriving stock (Show, Generic)
  deriving anyclass FromRow

-- instance FromRow ReturnedRow where
--   fromRow = do
--     count <- field
--     sysdate <- field
--     amount <- field
--     pure $ ReturnedRow{..}
