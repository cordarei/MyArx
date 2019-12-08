module ArxivUrlParser where

import Prelude (class Eq, class Applicative, Unit, bind, discard, pure, show, void, ($), (*>), (<$>), (<<<), (<>), (==))
import Control.Alt ((<|>))
import Control.Monad.Except.Trans (ExceptT(..))
import Data.Either (Either(..), either)
import Data.Tuple (Tuple(Tuple))

import Data.Array as Array
import Data.String.CodeUnits (fromCharArray)
import Text.Parsing.Parser (Parser, runParser)
import Text.Parsing.Parser.Combinators (optional, try)
import Text.Parsing.Parser.String (char, string)
import Text.Parsing.Parser.Token (digit)

data PageType = PDF | Abstract
derive instance showPageType :: Eq PageType

newtype ArxivId = ArxivId String
derive instance showArxivId :: Eq ArxivId

absURL :: ArxivId -> String
absURL (ArxivId i)= "https://www.arxiv.org/abs/" <> i

arxivParser :: Parser String (Tuple PageType ArxivId)
arxivParser = protocol *> domain *> page
  where
    protocol :: Parser String Unit
    protocol = do
      void (string "http")
      optional (char 's')
      void (string "://")

    domain :: Parser String Unit
    domain = do
      optional ((string "www.") <|> (string "export."))
      void (string "arxiv.org/")

    page :: Parser String (Tuple PageType ArxivId)
    page = do
      stype <- try (string "pdf") <|> string "abs"
      void (char '/')
      l <- fromCharArray <$> Array.many digit
      void (char '.')
      r <- fromCharArray <$> Array.many digit
      pure $ Tuple (if stype == "pdf" then PDF else Abstract) (ArxivId $ l <> "." <> r)

runArxivParser :: forall m . Applicative m => String -> ExceptT String m (Tuple PageType ArxivId)
runArxivParser s = ExceptT $ pure stringErrParser
  where
    stringErrParser :: Either String (Tuple PageType ArxivId)
    stringErrParser = either (Left <<< show) Right $ runParser s arxivParser


