module Test.Data.EitherR where

import Control.Alt ((<|>))
import Data.Either (Either(Left, Right))
import Data.EitherR (EitherR, succeed, runEitherR)
import Prelude (class Eq, (==), ($), return, bind)
import Test.Unit (test, TestSuite)
import Test.Unit.Assert as Assert

data TestError = TestError Int
instance eqTestError :: Eq TestError where
  eq (TestError i) (TestError j) = i == j


suite :: forall a. TestSuite a
suite = do
  test "EitherR monad" $ do
    let succeedResult = runEitherR $ do
                          x <- return 1
                          succeed 2
                          return x
    Assert.assert "`succeed` breaks execution chain with `Right` value" $
      succeedResult == Right 2
  test "EitherR alt" $ do
    let successesAggregation =
          succeed [1] <|>
          succeed [2] <|>
          (succeed [3] :: EitherR (Array Int) TestError)
    Assert.assert "`alt` aggregates results" $
      (runEitherR successesAggregation) == Right [1, 2, 3]
    let e1 = (successesAggregation <|> return (TestError 1) <|> return (TestError 2))
    Assert.assert "`alt` returns first error value" $
      (runEitherR e1) == Left (TestError 1)
