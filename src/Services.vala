using Vinject;
using Ensembles.ArrangerWorkstation;

namespace Ensembles.Services {
    static Injector di_container;

    static void handle_di_error (VinjectErrors e) {
        Console.log (
            "FATAL: Dependency injection error occurred! %s. Exiting…"
            .printf (e.message), Console.LogLevel.ERROR
        );
    }
}
