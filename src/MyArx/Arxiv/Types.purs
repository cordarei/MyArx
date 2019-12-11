module MyArx.Arxiv.Types where

import Prelude

data MyArxState
  = InArxiv
  | OutsideArxiv
  | InContainer

instance showMyArxState :: Show MyArxState where
  show InArxiv = "InArxiv"
  show OutsideArxiv = "OutsideArxiv"
  show InContainer = "InContainer"

type URL = String

data PageType = PDF | Abstract
derive instance eqPageType :: Eq PageType
instance showPageType :: Show PageType where
   show PDF = "PDF"
   show Abstract = "Abstract"

newtype ArxivId = ArxivId String
derive instance eqArxivId :: Eq ArxivId
instance showArxivId :: Show ArxivId where
   show (ArxivId i) = i

absURL :: ArxivId -> String
absURL (ArxivId i) = "https://www.arxiv.org/abs/" <> i

pdfURL :: ArxivId -> String
pdfURL (ArxivId i) = "https://arxiv.org/pdf/" <> i <> ".pdf"

newtype FirstAuthor = FirstAuthor String
derive instance eqFirstAuthor :: Eq FirstAuthor
instance showFirstAuthor :: Show FirstAuthor where
   show (FirstAuthor i) = i

newtype PublishYear = PublishYear String
derive instance eqPublishYear :: Eq PublishYear
instance showPublishYear :: Show PublishYear where
   show (PublishYear i) = i

newtype Title = Title String
derive instance eqTitle :: Eq Title
instance showTitle :: Show Title where
   show (Title i) = i

type UrlMetadata =
  { arxivId :: ArxivId
  , pageType :: PageType
  }

type Metadata = { url :: UrlMetadata, ex :: ExportMetadata }

type ExportMetadata =
  { title :: Title
  , firstAuthor :: FirstAuthor
  , publishYear :: PublishYear
  }

filename :: { title :: Title, firstAuthor :: FirstAuthor, publishYear :: PublishYear } -> String
filename md
  =  show md.title <> ", "
  <> show md.firstAuthor <> " et al., "
  <> show md.publishYear <> ".pdf"


