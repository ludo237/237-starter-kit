declare module '@inertiajs/core' {
    export interface InertiaConfig {
        sharedPageProps: {
            csrf: string;
            name: string;
            auth: {
                user: EloquentResource<User> | null;
            };
            sidebarOpen: boolean;
            [key: string]: unknown;
        };
    }
}
