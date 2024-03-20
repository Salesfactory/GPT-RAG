# Delete the gpt-rag-ingestion folder from .azure if it exists
if (Test-Path -Path ".\.salesfactory\gpt-rag-ingestion") {
    Remove-Item -Path ".\.salesfactory\gpt-rag-ingestion" -Recurse -Force
}

# Delete the gpt-rag-orchestrator folder from .azure if it exists
if (Test-Path -Path ".\.salesfactory\gpt-rag-orchestrator") {
    Remove-Item -Path ".\.salesfactory\gpt-rag-orchestrator" -Recurse -Force
}

# Delete the gpt-rag-frontend folder from .azure if it exists
if (Test-Path -Path ".\.salesfactory\gpt-rag-frontend") {
    Remove-Item -Path ".\.salesfactory\gpt-rag-frontend" -Recurse -Force
}
