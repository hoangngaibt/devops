FROM registry-dev.truesight.asia/truesight/aspnet:3.1-buster-slim AS base
WORKDIR /app

FROM registry-dev.truesight.asia/truesight/dotnet-sdk:3.1-buster AS build
WORKDIR /src
COPY ["Utils.csproj", ""]
RUN dotnet restore "Utils.csproj"
COPY . .
WORKDIR /src
RUN dotnet build "Utils.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Utils.csproj" -c Release -o /app/publish

FROM base AS final
RUN apt-get update && apt-get install -y net-tools curl iputils-ping telnet nano libc6-dev libgdiplus dnsutils

WORKDIR /app
EXPOSE 8080
USER root
RUN chmod -R g+w /app

COPY --from=publish /app/publish .

COPY ["docker-entrypoint.sh", "."]
RUN chmod a+x docker-entrypoint.sh
CMD ["./docker-entrypoint.sh"]
