module Test.Smoke.Types where

import Control.Exception (IOException)
import Data.ByteString (ByteString)

type TestName = String

type Executable = String

type Command = [String]

type Args = [String]

newtype Status = Status
  { unStatus :: Int
  } deriving (Eq, Show)

newtype StdIn = StdIn
  { unStdIn :: ByteString
  } deriving (Eq, Show)

newtype StdOut = StdOut
  { unStdOut :: ByteString
  } deriving (Eq, Show)

newtype StdErr = StdErr
  { unStdErr :: ByteString
  } deriving (Eq, Show)

data Options = Options
  { optionsCommand :: Maybe Command
  , optionsTestLocations :: [FilePath]
  } deriving (Eq, Show)

type Tests = [Test]

data Test = Test
  { testName :: TestName
  , testLocation :: FilePath
  , testCommand :: Maybe Command
  , testArgs :: Maybe Args
  , testStdIn :: Maybe FilePath
  , testStdOut :: [FilePath]
  , testStdErr :: [FilePath]
  , testStatus :: Status
  } deriving (Eq, Show)

data TestExecutionPlan = TestExecutionPlan
  { planTest :: Test
  , planExecutable :: Executable
  , planArgs :: Args
  , planStdIn :: Maybe StdIn
  } deriving (Eq, Show)

type TestResults = [TestResult]

data TestResult
  = TestSuccess Test
  | TestFailure TestExecutionPlan
                (PartResult Status)
                (PartResult StdOut)
                (PartResult StdErr)
  | TestError Test
              TestErrorMessage
  deriving (Eq, Show)

data PartResult a
  = PartSuccess
  | PartFailure [a]
                a
  deriving (Eq, Show)

instance Functor PartResult where
  _ `fmap` PartSuccess = PartSuccess
  f `fmap` (PartFailure expected actual) =
    PartFailure (map f expected) (f actual)

data TestErrorMessage
  = NoCommandFile
  | NoInputFiles
  | NoOutputFiles
  | NonExistentCommand
  | NonExecutableCommand
  | CouldNotExecuteCommand String
  | BlessingFailed IOException
  | CouldNotBlessStdOutWithMultipleValues
  | CouldNotBlessStdErrWithMultipleValues
  deriving (Eq, Show)
