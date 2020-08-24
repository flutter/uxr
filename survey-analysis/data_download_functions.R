# This function references R environment variables and pulls the data into your
# r workspace. Your R environment variables should named as follow:
# "QualtricsApiToken"
# "QualtricsSurveyID"

# To set environemnt variables, run the followings with your own information:
# Sys.setenv(QualtricsApiToken = "your_Qualtrics_API_token")
# Sys.setenv(QualtricsSurveyID = "your_survey_ID")

# To find your apiToken and surveyID,check out
# https://www.qualtrics.com/support/integrations/api-integration/finding-qualtrics-ids/

# To get and check environment varialbes, run the followings:
# Sys.getenv("QualtricsApiToken")
# Sys.getenv("QultricsSurveyID")
# Sys.getenv() # Displays all the environment variables

downloadQualtricsData <- function() {
  # requires curl and jsonlite
  library(curl)
  library(jsonlite)
  # reading in the authentication tokens and survey IDs:
  myAPIToken = Sys.getenv("QualtricsApiToken")
  mySurveyID = Sys.getenv("QualtricsSurveyID")
  # constructing and sending off the "export csv" request
  myHandle <- new_handle()
  handle_setopt(myHandle,
                copypostfields = paste('{ "surveyId":"',
                                       mySurveyID, '","format": "csv","useLabels":true}',
                                       sep=""
                )
  );
  handle_setheaders(
    myHandle,
    "X-API-TOKEN" = myAPIToken,
    "Content-Type" = "application/json"
  )
  raw_response <- curl_fetch_memory(
    "https://google.co1.qualtrics.com/API/v3/responseexports",
    handle = myHandle
  )
  if(raw_response$status_code!=200) {
    stop(
      paste(
        "There was an error issuing the export request.
        The request came back with status code:",
        raw_response$status_code,
        "\n"
      )
    )
  } else {
    cat("Successfully issued a request to Qualtrics
     to export data in a csv format.\n")
    resultID <- fromJSON(
      rawToChar(raw_response$content))$result$id
  }
  cat("Will wait 3 seconds for Qualtrics to export data...\n")
  Sys.sleep(3)
  # Checking to see if export is complete.
  myHandle <- new_handle()
  handle_setheaders(
    myHandle,
    "X-API-TOKEN" = myAPIToken,
    "Content-Type" = "application/json"
  )
  data_url <- paste(
    "https://google.co1.qualtrics.com/API/v3/responseexports/",
    resultID,
    sep = ""
  )
  repeat{
    response_export_progress <- curl_fetch_memory(
      data_url, 
      handle = myHandle
    )
    progress <- fromJSON(
      rawToChar(
        response_export_progress$content
      ))$result$percentComplete
    if(progress >= 100){
      break
    }
    cat(
      paste(
        "Qualtrics has not finished exporting yet (at ", progress, "%).
        Will wait 3 seconds to try again...\n",
        sep = ""
      )
    )
    Sys.sleep(3)
  }
  # Downloading and unzipping
  dir.create(file.path(getwd(), "data"), showWarnings = FALSE)
  curl_download(
    paste(
      data_url,
      "/file",
      sep = ""
    ),
    "data/results_file.zip",
    handle = myHandle,
    quiet = FALSE
  )
  cat(
    paste(
      "Downloaded results file to ",
      getwd(),
      "/data/results_file.zip\n",
      sep = ""
    )
  )
  unzip("data/results_file.zip", exdir = "data/")
  outputFilename <- unzip("data/results_file.zip", list = T)[1]
  cat(
    paste(
      "Done unzipping the data to ",
      getwd(),
      "/data/",
      outputFilename,
      "\n",
      sep = ""
    )
  )
  # Reading in the survey file into dSurvey and returning it
  dSurvey <- read.csv(
    paste(getwd(),
          "/data/",
          outputFilename,
          sep = ""
    ),
    header = FALSE,
    skip = 1,
    stringsAsFactors = F
  )
  variableNames <- read.csv(
    paste(
      getwd(),
      "/data/",
      outputFilename,
      sep = ""
    ),
    header = TRUE,
    nrows = 1
  )
  colnames(dSurvey) <- colnames(variableNames)
  # TODO: Delete the local copy
  return(dSurvey)
}
