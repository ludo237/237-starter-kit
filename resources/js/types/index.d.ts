import { InertiaLinkProps } from '@inertiajs/react';
import { LucideIcon } from 'lucide-react';

interface BreadcrumbItem {
    title: string;
    href: string;
}

interface NavGroup {
    title: string;
    items: NavItem[];
}

interface NavItem {
    title: string;
    href: NonNullable<InertiaLinkProps['href']>;
    icon?: LucideIcon | null;
    isActive?: boolean;
}

interface SharedData {
    csrf: string;
    auth: {
        user: EloquentResource<User> | null;
    };
    sidebarOpen: boolean;
    [key: string]: unknown;
}
