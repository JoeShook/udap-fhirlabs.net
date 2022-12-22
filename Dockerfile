#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
RUN mkdir -p /temp/_UDAP
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build

WORKDIR /src


COPY ["NuGet.Config", "."]
COPY ["FhirLabsApi.net.csproj", "."]
RUN dotnet restore -f  "FhirLabsApi.net.csproj"
COPY . .

WORKDIR "/src"
RUN dotnet build "FhirLabsApi.net.csproj" -c Release  -o /app/build

FROM build AS publish
RUN dotnet publish "FhirLabsApi.net.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS=http://*:8080
ENV ASPNETCORE_ENVIRONMENT release
ENV DOTNET_ENVIRONMENT release
ENTRYPOINT ["dotnet", "FhirLabsApi.net.dll" ]