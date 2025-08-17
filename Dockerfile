FROM astrocrpublic.azurecr.io/runtime:3.0-7

RUN curl -sSL install.astronomer.io | bash -s

RUN astro dev start