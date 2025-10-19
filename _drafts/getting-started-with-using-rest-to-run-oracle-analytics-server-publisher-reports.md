---
layout: post
title: Getting started with using REST to run Oracle Analytics Server Publisher reports
date: 2025-06-03 00:04 +0100
image: /assets/images/oracle_documentation_landing_page_250528.png

---
## Overview

In this tutorial, you'll learn how to use the REST API for Oracle Analytics Publisher to run reports and retrieve data in XML format. This tutorial is intended for software developers who want to know how to retrieve data using REST calls to Oracle Analytics Publisher. It assumes you have:

- access to an Oracle Analytics Server (OAS) system, and
- have some familiarity with:
  - [HTTP](https://developer.mozilla.org/en-US/docs/Glossary/HTTP) - The HyperText Transfer Protocol,
  - [REST](https://developer.mozilla.org/en-US/docs/Glossary/REST) - Representational State Transfer, and
  - [XML](https://developer.mozilla.org/en-US/docs/Glossary/XML) - eXtensible Markup Language.

By the end of this tutorial, you'll be able to understand how to make REST calls using `curl` to:

- authenticate with Oracle Analytics Server Publisher,
- get information about Publisher reports,
- run Publisher reports with or without parameters, and
- retrieve data in different formats.

## Background

- OAS Publisher is a reporting tool one can use to retrieve data from different data sources, and use it to produce basic lists of data to multiple tabs containing interactive graphics.
- Using REST, one can automate OAS Publisher to retrieve data, and reports in diferent formats. We have used it to extract and transform data before loading it into a Data Warehouse, where it was not possible to connect to the database directly.
- We are using curl in this tutorial so you can see the raw detail required. The programming language you intend using will likely have libraries that hide some of this detail, but knowing it will help you make use of the library.

## Before you start 

Before you start the tutorial, you should:

- be able to login to an instance of OAS Publisher and create Data Models and Reports,
- have access to the command line,
- have installed [curl](https://curl.se/) on your client machine, and
- have installed [jq](https://jqlang.org/) on your client machine.

## Get information about a Publisher report

The first step is to ensure you can authenticate with OAS, and know how to tell OAS which report you want to run. To get started, you must be able to authenticate with OAS Publisher, and make a REST call to fetch data.

The easiest kind of request is a `GET` request, and there are 5 to choose from the OAS Publisher [Manage Reports REST Endpoints](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/api-manage-reports.html). We'll use the [Get report definition](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/op-v1-reports-reportpath-get.html) which requires no more than passing your credentials and the location of a report.

Through the steps in this task you will learn how to authenticate with OAS Publisher, and construct the Endpoint URL to retrieve the definition of a report. We'll put commands in a `bash` script and build it up as we go along.

1. Create base64 encoded credentials.

    The Hypertext Transfer Protocol (HTTP) used by REST is in plain text, which allows us to see as much detail as we want. This first step creates the Authorisation header used to pass your credentials to OAS. The string you generate will look something like this:

    `Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=`

    The `Authorization:` is the name of the value and `Basic dXNlcm5hbWU6cGFzc3dvcmQ=` signifies we are using `Basic` authentication where the `dXNlcm5hbWU6cGFzc3dvcmQ=` part is the credentials in the form `username:password` after they have been base64 encoded.

    Put the following in a file called `oasREST`, replacing `username` and `password` with your credentials. Since it has your password in it make sure only you can see or execute it by running `chmod 700 oasREST`.

    ```bash
    # base64 encode your credentials
    export BIP_CREDENTIALS=$(echo -n 'username:password' | base64)
    # Display the Basic Authentication header that will be sent to OAS Publisher
    echo "Authorization: Basic $BIP_CREDENTIALS"
    ```

    Run the file such as by entering `/.oasREST`, and it will output the authentication string.

    The second line pipes your credentials into `base64` to encode them, and the result is assigned to BIP_CREDENTIALS variable to be used later.

    The last line echoes the authorization string to the screen so you can see it.

2. Create the URL we wil send as the endpoint to OAS Publisher.

    The URL we need to send to OAS Publisher needs to looks like `https://example.com:9502/xmlpserver/services/rest/v1/reports/{reportPath}`, which all looks fairly simple apart from the final `{reportPath}`. Let's work our way up to it. Every one of the 14 REST endpoints for managing reports, except one, begins like this.  The exception is the Create report endpoint.

    The beginning of the URL up to the end of the port is put into the `BIP_HOSTNAME` variable, although strictly speaking it is the Scheme, Hostname and optional port. This will make it easier to switch to another server.

    The next part is `/xmlpserver/services/rest/v1/reports/` which is always the same for every REST call for managing reports.

    The final part shown as `{reportPath}` represents the url-encoded path to the report we are interested in.  We will use `jq` to encode it here, but programming languages usually have their own way to achieve this. `jq` is another useful tool, we will use again later.

    Our report can be found under Shared Folders which means the path starts with the name of the first folder, "Reports for Tutorials", followed by the second, "REST", and ending with the report name which is "Simple REST Tutorial". The full path is "Reports for Tutorials/REST/Simple REST Tutorial". If it was under "My Folders" it would begin with a tilde (~) followed by my username, so would look like "~username/Reports for Tutorials/REST/Simple REST Tutorial".

    Add the following to the end of our `oasREST` file, substituting my reportPath for yours.

    ```bash

    # Store the Scheme, Hostname and Port in a variable and display the value
    # The port can be left out if it is 80
    export BIP_HOSTNAME=https://ple-up-oas.usingprimavera.com:9502
    echo $BIP_HOSTNAME

    # Store the path to the report in an environment variable and display the value
    export BIP_REPORT_PATH="Reports for Tutorials/REST/Simple REST Tutorial"
    echo $BIP_REPORT_PATH

    # Use `jq` to URL encode the contents of BIP_REPORT_PATH, storing it in a variable
    # and displaying the result
    export BIP_ENC_REPORT_PATH=$(jq -rn --arg x "$BIP_REPORT_PATH" '$x|@uri')
    echo $BIP_ENC_REPORT_PATH

    # Now make up the endpoint using the environment variables and static text
    echo "$BIP_HOSTNAME/xmlpserver/services/rest/v1/reports/$BIP_ENC_REPORT_PATH"
    ```

3. Use `curl` to call the Get Report definition endpoint.

    We will now use `curl` to make the REST call to OAS, and return the result using what we have built so far.

    Add the following at the end of the `oasREST` file.

    ```bash
    # the curl statement is continued on multiple lines as we feel it is clearer.
    curl -i \
      -H "Authorization: Basic $BIP_CREDENTIALS" \
      --request GET "$BIP_HOSTNAME/xmlpserver/services/rest/v1/reports/$BIP_ENC_REPORT_PATH"
    ```

    
    # This is the response I received where the first line, "HTTP/1.1 200 OK" tells me it was successful.
    #
    HTTP/1.1 200 OK
    Cache-Control: no-store
    Date: Thu, 17 Jul 2025 19:29:15 GMT
    Pragma: no-cache
    Content-Length: 1221
    Content-Type: application/json
    Content-Security-Policy: default-src 'self' ; script-src 'self' 'unsafe-inline' 'unsafe-eval' ; style-src 'self' 'unsafe-inline' ; style-src-elem 'self'  'unsafe-inline'; img-src 'self'  data:; frame-src 'self'  data:; media-src 'none'; form-action 'self' ; object-src 'none' ; frame-ancestors 'self'                                                   │
    X-ORACLE-DMS-RID: 0
    X-ORACLE-DMS-ECID: ffe4a7df-2b78-48a5-8f32-187f1554371f-00000fa7
    X-FRAME-OPTIONS: SAMEORIGIN
    
    {"ESSPackageName":"","ESSJobName":"","autoRun":"true","cacheDocument":"true","controledByExtApp":"false","dataModelURL":"/Reports for Tutorials/REST/Datamodels/Simple RestTutorial.xdm","defaultOutputFormat":"analyze","defaultTemplateId":"Data","diagnostics":"false","listOfTemplateFormatsLabelValues":{"item":[{"active":"true","applyStyleTemplate":"true","default":"false","listOfTemplateFormatLabelValue":{"item":[{"templateFormatLabel":"Interactive","templateFormatValue":"analyze"},{"templateFormatLabel":"HTML","templateFormatValue":"html"},{"templateFormatLabel":"PDF","templateFormatValue":"pdf"},{"templateFormatLabel":"RTF","templateFormatValue":"rtf"},{"templateFormatLabel":"Excel (*.xlsx)","templateFormatValue":"xlsx"},{"templateFormatLabel":"PowerPoint (*.pptx)","templateFormatValue":"pptx"}]},"templateAvailableLocales":{"item":["en_US"]},"templateBaseLocale":null,"templateDefaultLocale":"en_US","templateID":"Data","templateType":"xpt","templateURL":"Data.xpt","viewOnline":"true"}]},"onLine":"true","openLinkInNewWindow":"true","parameterColumns":3,"reportDefnTitle":"","reportName":"Simple REST Tutorial","reportType":null,"showControls":"true","showReportLinks":"true","templateIds":{"item":["Data"]}}
    ```

    There is quite a lot of information returned here, but we don't necessarily need to know what all of it means.


## Run a Publisher report to retrieve data

## Run publisher reports with different kinds of parameters.

## Retrieve content in different formats.

## {Task name}

To get started, {the first thing your user should do}.

1. {Write the step here. Use a verb to start.}

    {Explanatory text}

    {Optional: Code sample or screenshot that helps your users complete this step}

    {Optional: Result}

2. {Write the step here. Use a verb to start.}
   
   a. {Substep 1}

   b. {Substep 1} 



## Summary

{Use this section to summarize what the user learned in the tutorial.}

In this tutorial, you learned how to:

* Summary point 1
* Summary point 2
* Summary point 3..

## Next steps

{Use this section to share links to related tutorials, videos, or other documentation}.

Consider completing some other common tasks using {feature}:

* Task 1
* Task 2
* Task 3...

## Notes to be deleted 


