FROM microsoft/dotnet:2.2-sdk

#---------Argumentos
ARG TimeZone
ARG SONAR_SCANNER_DOTNET_VERSION
ARG COVERLET_CONSOLE_VERSION


#---------Configura o TimeZone
RUN ln -snf /usr/share/zoneinfo/$TimeZone /etc/localtime \
    && echo $TimeZone > /etc/timezone

#---------Instalando ferramentas
RUN dotnet tool install --global coverlet.console --version ${COVERLET_CONSOLE_VERSION}
RUN dotnet tool install --global dotnet-sonarscanner --version ${SONAR_SCANNER_DOTNET_VERSION}
ENV PATH "$PATH:/root/.dotnet/tools/"


#---------Copia os arquivos de configurações
COPY ./config/Nuget.Config /root/.nuget/NuGet/NuGet.Config
COPY ./config/SonarQube.Analysis.xml /root/.dotnet/tools/.store/dotnet-sonarscanner/${SONAR_SCANNER_DOTNET_VERSION}/dotnet-sonarscanner/${SONAR_SCANNER_DOTNET_VERSION}/tools/netcoreapp2.1/any/