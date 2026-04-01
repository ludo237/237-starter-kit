declare module '@inertiajs/core' {
    export interface InertiaConfig {
        sharedPageProps: {
            csrf: string;
            name: string;
            auth: {
                user: EloquentResource<User> | null;
            };
            currentTeam: Team | null;
            teams: Team[];
            sidebarOpen: boolean;
            [key: string]: unknown;
        };
    }
}
