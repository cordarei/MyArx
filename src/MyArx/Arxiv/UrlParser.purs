module MyArx.Arxiv.UrlParser where

import Prelude
import Control.Alt ((<|>))
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Either (Either(..), either)
import Data.Tuple (Tuple(Tuple))
import Data.Array as Array
import Data.String.CodeUnits (fromCharArray)
import Text.Parsing.Parser (Parser, runParser)
import Text.Parsing.Parser.Combinators (optional, try)
import Text.Parsing.Parser.String (char, string)
import Text.Parsing.Parser.Token (digit)

import MyArx.Arxiv.Types

arxivParser :: Parser String UrlMetadata
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

    page :: Parser String UrlMetadata
    page = do
      stype <- try (string "pdf") <|> string "abs"
      void (char '/')
      l <- fromCharArray <$> Array.many digit
      void (char '.')
      r <- fromCharArray <$> Array.many (digit <|> char 'v')
      when (stype == "abs") (optional $ string ".pdf")
      pure
        { pageType: if stype == "pdf" then PDF else Abstract
        , arxivId: ArxivId $ l <> "." <> r
        }

runArxivParser
  :: forall m
  .  Applicative m
  => String
  -> m (Either String UrlMetadata)
runArxivParser = runExceptT <<< runArxivParserT

runArxivParserT
  :: forall m
  .  Applicative m
  => String
  -> ExceptT String m UrlMetadata
runArxivParserT s = ExceptT $ pure
  $ either (Left <<< show) Right
  $ runParser s arxivParser


