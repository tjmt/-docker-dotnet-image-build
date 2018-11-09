#!/bin/bash

echo '_____________Iniciando criacao do arquivo NuGet.Config_____________'

if [ "${NUGET_SOURCE_EXTERNO}" != "" ]; then \
    NUGET_FILE_SOURCE_EXTERNO="<add key=\"source_externo\" value=\"$NUGET_SOURCE_EXTERNO\" protocolVersion=\"3\" />";\
fi

if [ "${NUGET_SOURCE_INTERNO}" != "" ]; then \
    NUGET_FILE_SOURCE_INTERNO="<add key=\"source_interno\" value=\"$NUGET_SOURCE_INTERNO\" />"; \
fi

if [ "${HTTP_PROXY}" != "" ]; then \
    NUGET_FILE_HTTP_PROXY="<add key=\"http_proxy\" value=\"$HTTP_PROXY\" />"; \
fi

if [ "${HTTP_PROXY_USER}" != "" ]; then \
    NUGET_FILE_HTTP_PROXY_USER="<add key=\"http_proxy.user\" value=\"$HTTP_PROXY_USER\" />"; \
fi

if [ "${HTTP_PROXY_PASSWORD}" != "" ]; then \
    NUGET_FILE_HTTP_PROXY_PASSWORD="<add key=\"http_proxy.password\" value=\"$HTTP_PROXY_PASSWORD\" />"; \
fi

echo $NUGET_FILE_SOURCE_EXTERNO
echo $NUGET_FILE_SOURCE_INTERNO
echo $NUGET_FILE_HTTP_PROXY
echo $NUGET_FILE_HTTP_PROXY_USER
echo $NUGET_FILE_HTTP_PROXY_PASSWORD

NUGET_FILE_CONTENT="<?xml version=\"1.0\" encoding=\"utf-8\"?>
<configuration>
    <packageRestore>
        <add key=\"enabled\" value=\"True\" />
        <add key=\"automatic\" value=\"True\" />
    </packageRestore>
    <bindingRedirects>
        <add key=\"skip\" value=\"False\" />
    </bindingRedirects>
    <packageManagement>
        <add key=\"format\" value=\"0\" />
        <add key=\"disabled\" value=\"False\" />
    </packageManagement>
    <config>
        <add key=\"dependencyVersion\" value=\"Highest\" />
        ${NUGET_FILE_HTTP_PROXY}
        ${NUGET_FILE_HTTP_PROXY_USER}
        ${NUGET_FILE_HTTP_PROXY_PASSWORD}
    </config>
    <packageSources>
        ${NUGET_FILE_SOURCE_EXTERNO}
        ${NUGET_FILE_SOURCE_INTERNO}
    </packageSources>
</configuration>"

echo $NUGET_FILE_CONTENT
echo $NUGET_FILE_CONTENT > /root/.nuget/NuGet/NuGet.Config