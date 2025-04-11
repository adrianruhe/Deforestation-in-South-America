# FRONTEND

This folder contains the code for the backend of the application, running an [Angular](https://angular.io/) framework.

## Angular

For additional information regarding angular, please read the [documentation](https://angular.io/docs). As _Components_ and _Services_ are important concepts, a short explanation is provided here.

### Components

Angular Components are the building blocks of an Angular application. A component is essentially a TypeScript class with a template that defines a view. The view is what the user sees on the page, and it's defined using HTML and Angular's template syntax. Components are reusable and can be combined to create complex user interfaces. Each component is responsible for a specific part of the user interface and can interact with other components.

A new component can be created via the [Angular CLI](https://angular.io/cli) by running `ng generate component <component-name>`. This will create a new folder with the corresponding files (.html, .scss & .ts) and register the component in the `app.module.ts`. Make sure your console is navigated to the folder where you want to create the component (e.g. `src/app/components/`).

### Services

Angular Services are classes that provide functionality to multiple components throughout an application. Services are used to perform tasks that are not related to a specific view or component, such as fetching data from a server or handling authentication. Services are designed to be reusable and can be injected into any component that needs them. Services are typically singletons, meaning that there is only one instance of each service throughout the entire application.

A new service can be created via the [Angular CLI](https://angular.io/cli) by running `ng generate service <service-name>`.

### Modules

In Angular, modules are a way to organize and structure your application. They help you encapsulate related functionality, manage dependencies, and promote code reusability.

The `app.module.ts` file is the main module file of an Angular application. It declares the root module (e.g., AppModule), and all other components that you create, making them accessible in all other components.
Core and shared modules that are used globally throughout your application (e.g. [Angular Material](https://material.angular.io/) Modules) should be imported in the `app.module.ts`. Other modules that are only needed by one specific component can be imported directly in the respective subcomponent.

## Add packages

To add additional node packages, you can use [npm](https://www.npmjs.com/) (node package manager). Using the console, navigate to the `frontend/code` folder (where the `package.json` file is located), and simply type `npm install 'package name'`. You will need to rebuild the frontend (`docker-compose build frontend`) for the package to be properly installed in the docker container. Some essential packages ([d3](https://d3js.org/), [leaflet](https://leafletjs.com/), [angular material](https://material.angular.io/)) are already installed.

To see which packages (and versions) are already installed, check out the `code/package.json` file.