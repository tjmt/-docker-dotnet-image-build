FROM microsoft/dotnet:2.1-sdk

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

#---------Copiando arquivos sh para de continuous integration para entrypoint
COPY ./entrypoint-ci /entrypoint-ci
RUN chmod +x /entrypoint-ci/continuous-integration.sh
RUN chmod +x /entrypoint-ci/wait-for-it.sh

#Variaveis de ambiente com valores padrões. É possivel mudar estes valores, informando no docker run ou no docker-compose
ENV COVERAGE_PATH="/TestResults/codecoverage"
ENV RESULT_PATH="/TestResults/result"

#---------COMANDOS ONBUILD (serão rodados no Dockerfile de quem herdar desta imagem)
#Argumentos
ONBUILD ARG CONFIGURATION="Release"
ONBUILD ARG SOLUTION_NAME=""

#Criando variaveis de ambientes com os argumentos, necessário para rodar o CI (entrypoint)
ONBUILD ENV CONFIGURATION=$CONFIGURATION
ONBUILD ENV SOLUTION_NAME=$SOLUTION_NAME

#Criando estrutura final de pasta
ONBUILD RUN mkdir /app \ 
&& mkdir /packages \ 
&& mkdir /TestResults

#Copiando arquivos para dentro do estágio build
ONBUILD WORKDIR /src
ONBUILD COPY . .

#Restaurando pacotes nuget da solução
ONBUILD RUN if [ "${SOLUTION_NAME}" = "" ]; then \  
                dotnet restore -v m; \
            else \
                dotnet restore ${SOLUTION_NAME} -v m; \
            fi

#Buildando solução
ONBUILD RUN if [ "${SOLUTION_NAME}" = "" ]; then \  
                dotnet build -c ${CONFIGURATION} --no-restore -v m; \
            else \
                dotnet build ${SOLUTION_NAME} -c ${CONFIGURATION} --no-restore -v m; \
            fi