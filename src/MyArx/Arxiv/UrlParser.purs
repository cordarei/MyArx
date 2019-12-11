module MyArx.Arxiv.UrlParser where

import Prelude
import Debug.Trace
import Control.Alt ((<|>))
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)
import Data.Either (Either(..), either)
import Data.Tuple (Tuple(Tuple))
import Data.Array as Array
import Data.String.CodeUnits (fromCharArray)
import Text.Parsing.Parser (Parser, runParser)
import Text.Parsing.Parser.Combinators (optional, try)
import Text.Parsing.Parser.String (char, string)
import Text.Parsing.Parser.Token (digit, alphaNum)

import MyArx.Arxiv.Types

protocol :: Parser String Unit
protocol = void $ (string "http") *> optional (char 's') *> (string "://")

arxivDomain :: Parser String Unit
arxivDomain = do
  optional ((string "www.") <|> (string "export."))
  void (string "arxiv.org/")

uri2PageType :: Parser String PageType
uri2PageType = do
  stype <- try (string "pdf") <|> string "abs"
  void (char '/')
  pure $ if stype == "pdf" then PDF else Abstract

arxivUri :: Parser String UrlMetadata
arxivUri = do
  pt <- uri2PageType
  l <- fromCharArray <$> Array.many digit
  void (char '.')
  r <- fromCharArray <$> Array.many (digit <|> char 'v')
  when (pt == Abstract) (optional $ string ".pdf")
  pure
    { pageType: pt
    , arxivId: ArxivId $ l <> "." <> r
    }

arxivUrl :: Parser String UrlMetadata
arxivUrl = protocol *> arxivDomain *> arxivUri

mozext :: Parser String Unit
mozext = do
  void $ string "moz-extension://"
  void $ Array.many (alphaNum <|> char '-')


pdfviewerWithTarget :: Parser String Unit
pdfviewerWithTarget = void $ string "/pdfviewer.html?target="

viewerUrl :: Parser String UrlMetadata
viewerUrl = mozext *> pdfviewerWithTarget *> arxivUrl

runMyArxParser
  :: forall m r
  .  Applicative m
  => Parser String r
  -> String
  -> m (Either String r)
runMyArxParser p s = (runExceptT <<< runMyArxParserT p) (spy "running parser" s)

runMyArxParserT
  :: forall m r
  .  Applicative m
  => Parser String r
  -> String
  -> ExceptT String m r
runMyArxParserT p s = ExceptT $ pure
  $ either (Left <<< show) Right
  $ runParser s p


