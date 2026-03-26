---
title: How to authenticate using REST with OAS Publisher
date: 2025-10-19 22:02 +0100
last_modified_date: 2025-10-19T22:02:00+01:00
nav_order: 1
product: oas
image: /assets/images/oracle_documentation_landing_page_250528.png
---
## Overview

This is the first tutorial in a series of tutorials intended for software developers who want to know how to make use of REST with OAS Publisher.

In this tutorial, you'll learn how to
- authenticate with Oracle Analytics Server (OAS) Publisher using the REST API,
- provide the location of a report, and
- retrieve report definition data from OAS Publisher.

This tutorial assumes you have:

- access to an Oracle Analytics Server (OAS) system, and
- have some familiarity with:
  - [HTTP](https://developer.mozilla.org/en-US/docs/Glossary/HTTP) - The HyperText Transfer Protocol,
  - [REST](https://developer.mozilla.org/en-US/docs/Glossary/REST) - Representational State Transfer, and
  - [JSON](https://developer.mozilla.org/en-US/docs/Glossary/JSON) - JavaScript Object Notation.

By the end of this tutorial, you'll be able to:

- create base64 encoded credentials for HTTP Basic Authentication,
- construct the endpoint URL for OAS Publisher REST calls, and
- use `curl` to make authenticated REST requests to OAS Publisher.

## Background

All the REST calls made to OAS Publisher require authentication, so this short tutorial is essential for using REST with OAS Publisher, and it also ensures you have the tools installed for the rest of the tutorials in this series.

We use `curl` and `jq` throughout these tutorials, because they allow us to see the detail, which may be abstracted away into libraries when using your programming language of choice.

## Before you start

Before you start the tutorial, you should:

- be able to login to an instance of OAS Publisher and create Data Models and Reports,
- have access to the command line,
- install [curl](https://curl.se/) on your client machine, and
- install [jq](https://jqlang.org/) on your client machine.

## Get information about a Publisher report

This short tutorial will retrieve information about an OAS Publisher report you have access to, using a simkple `GET` request. There are 5 to choose from the OAS Publisher [Manage Reports REST Endpoints](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/api-manage-reports.html). We'll use the [Get report definition](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/op-v1-reports-reportpath-get.html) which requires passing your credentials along with the location of a report.

Through the steps in this task you will learn how to authenticate with OAS Publisher, and construct the endpoint URL to retrieve the definition of a report. We'll put commands in a `bash` script and build it up as we go along.

1. Create base64 encoded credentials.

    The Hypertext Transfer Protocol (HTTP) used by REST is in plain text, allowing us to see as much detail as we want. This first step creates the Authorisation header used to pass your credentials to OAS. It generates a string that looks something like this:

    `Authorization: Basic dXNlcm5hbWU6cGFzc3dvcmQ=`

    The `Authorization:` is the name of the value and `Basic dXNlcm5hbWU6cGFzc3dvcmQ=` signifies we are using `Basic` authentication where the `dXNlcm5hbWU6cGFzc3dvcmQ=` part is the credentials in the form `username:password` after they have been base64 encoded.

    Put the following in a file called `oasREST`, replacing `username` and `password` with your credentials. Since it has your password in it make sure only you can see or execute it by running `chmod 700 oasREST`.

    ```bash
    # base64 encode your credentials
    export BIP_CREDENTIALS=$(echo -n 'username:password' | base64)
    # Display the Basic Authentication header that will be sent to OAS Publisher
    echo "Authorization: Basic $BIP_CREDENTIALS"
    ```

    Run the file such as by entering `./oasREST`, and it will output the authentication string.

    The second line pipes your credentials into `base64` to encode them, and the result is assigned to BIP_CREDENTIALS variable to be used later.

    The last line echoes the authorization string to the screen so you can see it.

2. Create the URL we will send as the endpoint to OAS Publisher.

    The URL we need to send to OAS Publisher needs to looks like `https://example.com:9502/xmlpserver/services/rest/v1/reports/{reportPath}`, which all looks fairly simple apart from the final `{reportPath}`. Let's work our way through this. Every one of the 14 REST endpoints for managing reports, except one, begins like this.  The exception is the Create report endpoint.

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

    This is the response I received where the first line, `HTTP/1.1 200 OK`, tells me the request was successful:

    ```
    HTTP/1.1 200 OK
    Cache-Control: no-store
    Date: Thu, 17 Jul 2025 19:29:15 GMT
    Pragma: no-cache
    Content-Length: 1221
    Content-Type: application/json
    X-ORACLE-DMS-RID: 0
    X-ORACLE-DMS-ECID: ffe4a7df-2b78-48a5-8f32-187f1554371f-00000fa7
    X-FRAME-OPTIONS: SAMEORIGIN

    {"ESSPackageName":"","ESSJobName":"","autoRun":"true","cacheDocument":"true",
    "controledByExtApp":"false","dataModelURL":"/Reports for Tutorials/REST/Datamodels/Simple RestTutorial.xdm",
    "defaultOutputFormat":"analyze","defaultTemplateId":"Data","diagnostics":"false",
    "listOfTemplateFormatsLabelValues":{"item":[{"active":"true","applyStyleTemplate":"true",
    "default":"false","listOfTemplateFormatLabelValue":{"item":[
    {"templateFormatLabel":"Interactive","templateFormatValue":"analyze"},
    {"templateFormatLabel":"HTML","templateFormatValue":"html"},
    {"templateFormatLabel":"PDF","templateFormatValue":"pdf"},
    {"templateFormatLabel":"RTF","templateFormatValue":"rtf"},
    {"templateFormatLabel":"Excel (*.xlsx)","templateFormatValue":"xlsx"},
    {"templateFormatLabel":"PowerPoint (*.pptx)","templateFormatValue":"pptx"}]},
    "templateAvailableLocales":{"item":["en_US"]},"templateBaseLocale":null,
    "templateDefaultLocale":"en_US","templateID":"Data","templateType":"xpt",
    "templateURL":"Data.xpt","viewOnline":"true"}]},"onLine":"true",
    "openLinkInNewWindow":"true","parameterColumns":3,"reportDefnTitle":"",
    "reportName":"Simple REST Tutorial","reportType":null,"showControls":"true",
    "showReportLinks":"true","templateIds":{"item":["Data"]}}
    ```

    The response contains the report definition in JSON format. There is quite a lot of information returned here, but we don't necessarily need to know what all of it means. The key point is that we successfully authenticated and retrieved data from OAS Publisher.


## Summary

In this tutorial, you learned how to:

- create base64 encoded credentials using the `username:password` format required by HTTP Basic Authentication,
- construct the endpoint URL for OAS Publisher REST calls, including URL-encoding the report path using `jq`, and
- use `curl` to make an authenticated REST request to the OAS Publisher API and retrieve report definition data.

These skills form the foundation for all the REST calls you will make to OAS Publisher in the tutorials that follow.

## Next steps

Now that you can authenticate with OAS Publisher, you're ready to start running reports:

- **Run a report without parameters** - Learn how to execute a simple report and retrieve its output in XML format.
- **Extract XML data from report output** - Learn how to process and extract the data returned by OAS Publisher.
- **Run reports with parameters** - Learn how to pass text, number, date, and list parameters to reports.

You may also find the [OAS Publisher REST API documentation](https://docs.oracle.com/en/middleware/bi/analytics-server/oap_rest_api/index.html) useful as a reference.
