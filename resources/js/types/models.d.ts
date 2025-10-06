interface Model {
    readonly id: string;
    readonly createdAt: string;
    readonly updatedAt: string;
}

interface SoftDeleteModel {
    readonly deletedAt: string | null;
}

interface User extends Model, SoftDeleteModel {
    name: string;
    email: string;
    emailVerifiedAt: string | null;
    twoFactor: {
        enabledAt: string | null;
    };
}
