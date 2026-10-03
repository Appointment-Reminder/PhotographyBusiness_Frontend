import { useState, useRef } from 'react';

type Package = 'A' | 'B' | 'C';
type KanbanStatus = 'needs_assignment' | 'pending_selection' | 'pending_editing' | 'pending_review';

interface Photographer {
    id: string;
    name: string;
    color: string;
    initials: string;
}

interface Appointment {
    id: string;
    clientName: string;
    package: Package;
    status: KanbanStatus;
    photographerId: string | null;
    date: string;
}

const PHOTOGRAPHERS: Photographer[] = [
    { id: 'p1', name: 'Léa Moreau',     color: '#c7522a', initials: 'LM' },
    { id: 'p2', name: 'Jules Fontaine',  color: '#3b6fd4', initials: 'JF' },
    { id: 'p3', name: 'Camille Voss',   color: '#2a8a5a', initials: 'CV' },
    { id: 'p4', name: 'Noé Bellamy',    color: '#7c4dbd', initials: 'NB' },
];

const INITIAL_APPOINTMENTS: Appointment[] = [
    { id: 'a1',  clientName: 'Martine Dupont',    package: 'A', status: 'needs_assignment',  photographerId: null,  date: '2026-10-02' },
    { id: 'a2',  clientName: 'Thomas Bernard',    package: 'B', status: 'needs_assignment',  photographerId: null,  date: '2026-10-05' },
    { id: 'a3',  clientName: 'Isabelle Garnier',  package: 'C', status: 'needs_assignment',  photographerId: null,  date: '2026-10-08' },
    { id: 'a4',  clientName: 'Marc Lefebvre',     package: 'A', status: 'pending_selection', photographerId: 'p1',  date: '2026-10-01' },
    { id: 'a5',  clientName: 'Sophie Renard',     package: 'B', status: 'pending_selection', photographerId: 'p2',  date: '2026-09-28' },
    { id: 'a6',  clientName: 'Étienne Morel',     package: 'C', status: 'pending_selection', photographerId: 'p3',  date: '2026-09-30' },
    { id: 'a7',  clientName: 'Claire Simon',      package: 'A', status: 'pending_editing',   photographerId: 'p2',  date: '2026-09-22' },
    { id: 'a8',  clientName: 'François Laurent',  package: 'B', status: 'pending_editing',   photographerId: 'p4',  date: '2026-09-20' },
    { id: 'a9',  clientName: 'Amandine Petit',    package: 'A', status: 'pending_editing',   photographerId: 'p1',  date: '2026-09-18' },
    { id: 'a10', clientName: 'David Girard',      package: 'C', status: 'pending_review',    photographerId: 'p3',  date: '2026-09-15' },
    { id: 'a11', clientName: 'Nathalie Rousseau', package: 'B', status: 'pending_review',    photographerId: 'p1',  date: '2026-09-12' },
];

const COLUMNS: { id: KanbanStatus; label: string; description: string }[] = [
    { id: 'needs_assignment',  label: 'Needs Assignment',  description: 'Unassigned shoots' },
    { id: 'pending_selection', label: 'Pending Selection', description: 'Awaiting client pick' },
    { id: 'pending_editing',   label: 'Pending Editing',   description: 'In post-production' },
    { id: 'pending_review',    label: 'Pending Review',    description: 'Ready for final check' },
];

const PACKAGE_LABELS: Record<Package, string> = { A: 'Pkg A', B: 'Pkg B', C: 'Pkg C' };

function getPhotographer(id: string | null): Photographer | undefined {
    return PHOTOGRAPHERS.find(p => p.id === id);
}

function AppointmentCard({
                             appointment,
                             onDragStart,
                             onMarkDone,
                             onAssign,
                         }: {
    appointment: Appointment;
    onDragStart: (id: string) => void;
    onMarkDone: (id: string) => void;
    onAssign: (id: string, photographerId: string) => void;
}) {
    const [showAssign, setShowAssign] = useState(false);
    const photographer = getPhotographer(appointment.photographerId);

    return (
        <div
            draggable
            onDragStart={() => onDragStart(appointment.id)}
            className="group relative bg-card border border-border rounded-lg p-3 cursor-grab active:cursor-grabbing transition-all hover:shadow-sm hover:border-border/80"
        >
            {/* Photographer color bar */}
            <div
                className="absolute left-0 top-2 bottom-2 w-[3px] rounded-full"
                style={{ backgroundColor: photographer?.color ?? '#cbced4' }}
            />

            <div className="pl-3">
                {/* Client name */}
                <p className="text-foreground text-sm font-medium leading-tight mb-2">
                    {appointment.clientName}
                </p>

                <div className="flex items-center justify-between gap-2">
                    {/* Package badge */}
                    <span
                        className="text-[10px] tracking-widest text-muted-foreground bg-muted px-1.5 py-0.5 rounded"
                        style={{ fontFamily: 'var(--font-mono)' }}
                    >
            {PACKAGE_LABELS[appointment.package]}
          </span>

                    {/* Photographer avatar or assign */}
                    {photographer ? (
                        <div
                            className="w-6 h-6 rounded-full flex items-center justify-center text-[9px] font-semibold text-white flex-shrink-0"
                            style={{ backgroundColor: photographer.color }}
                            title={photographer.name}
                        >
                            {photographer.initials}
                        </div>
                    ) : (
                        <button
                            onClick={() => setShowAssign(!showAssign)}
                            className="text-[10px] text-muted-foreground hover:text-foreground transition-colors border border-dashed border-border px-1.5 py-0.5 rounded hover:border-foreground/20"
                        >
                            + assign
                        </button>
                    )}
                </div>

                {/* Assign dropdown */}
                {showAssign && (
                    <div className="mt-2 border border-border rounded-md overflow-hidden bg-card shadow-md">
                        {PHOTOGRAPHERS.map(p => (
                            <button
                                key={p.id}
                                onClick={() => { onAssign(appointment.id, p.id); setShowAssign(false); }}
                                className="w-full flex items-center gap-2 px-2.5 py-2 hover:bg-accent transition-colors text-left"
                            >
                                <div className="w-3 h-3 rounded-full flex-shrink-0" style={{ backgroundColor: p.color }} />
                                <span className="text-xs text-foreground">{p.name}</span>
                            </button>
                        ))}
                    </div>
                )}

                {/* Date + done */}
                <div className="flex items-center justify-between mt-2.5 pt-2 border-t border-border">
          <span className="text-[10px] text-muted-foreground" style={{ fontFamily: 'var(--font-mono)' }}>
            {new Date(appointment.date).toLocaleDateString('en-GB', { day: '2-digit', month: 'short' })}
          </span>
                    <button
                        onClick={() => onMarkDone(appointment.id)}
                        className="text-[10px] text-muted-foreground hover:text-green-600 transition-colors opacity-0 group-hover:opacity-100"
                    >
                        mark done ✓
                    </button>
                </div>
            </div>
        </div>
    );
}

function Column({
                    column,
                    appointments,
                    onDragStart,
                    onDrop,
                    onMarkDone,
                    onAssign,
                }: {
    column: typeof COLUMNS[number];
    appointments: Appointment[];
    onDragStart: (id: string) => void;
    onDrop: (status: KanbanStatus) => void;
    onMarkDone: (id: string) => void;
    onAssign: (id: string, photographerId: string) => void;
}) {
    const [isDragOver, setIsDragOver] = useState(false);

    return (
        <div
            className={`flex flex-col min-h-0 rounded-xl p-3 transition-all ${
                isDragOver ? 'bg-accent ring-1 ring-border' : 'bg-muted/50'
            }`}
            onDragOver={e => { e.preventDefault(); setIsDragOver(true); }}
            onDragLeave={() => setIsDragOver(false)}
            onDrop={() => { onDrop(column.id); setIsDragOver(false); }}
        >
            {/* Column header */}
            <div className="mb-3 px-1">
                <div className="flex items-center justify-between mb-0.5">
                    <h2 className="text-xs font-semibold tracking-wide text-foreground">
                        {column.label}
                    </h2>
                    <span
                        className="text-[10px] text-muted-foreground tabular-nums bg-background border border-border rounded px-1.5 py-0.5"
                        style={{ fontFamily: 'var(--font-mono)' }}
                    >
            {appointments.length}
          </span>
                </div>
                <p className="text-[10px] text-muted-foreground">{column.description}</p>
            </div>

            {/* Cards */}
            <div className="flex flex-col gap-2 flex-1 overflow-y-auto">
                {appointments.length === 0 && (
                    <div className="flex items-center justify-center h-14 border border-dashed border-border rounded-lg">
                        <span className="text-[10px] text-muted-foreground/50">empty</span>
                    </div>
                )}
                {appointments.map(apt => (
                    <AppointmentCard
                        key={apt.id}
                        appointment={apt}
                        onDragStart={onDragStart}
                        onMarkDone={onMarkDone}
                        onAssign={onAssign}
                    />
                ))}
            </div>
        </div>
    );
}

export default function App() {
    const [appointments, setAppointments] = useState<Appointment[]>(INITIAL_APPOINTMENTS);
    const [filterPhotographer, setFilterPhotographer] = useState<string | null>(null);
    const dragId = useRef<string | null>(null);

    const handleDragStart = (id: string) => { dragId.current = id; };

    const handleDrop = (status: KanbanStatus) => {
        if (!dragId.current) return;
        setAppointments(prev =>
            prev.map(a => a.id === dragId.current ? { ...a, status } : a)
        );
        dragId.current = null;
    };

    const handleMarkDone = (id: string) => {
        setAppointments(prev => prev.filter(a => a.id !== id));
    };

    const handleAssign = (id: string, photographerId: string) => {
        setAppointments(prev =>
            prev.map(a => a.id === id ? { ...a, photographerId } : a)
        );
    };

    const visibleAppointments = filterPhotographer
        ? appointments.filter(a => a.photographerId === filterPhotographer)
        : appointments;

    return (
        <div className="min-h-screen bg-background flex flex-col">

            {/* Header */}
            <header className="border-b border-border bg-card px-6 py-3 flex items-center justify-between flex-shrink-0">
                <div>
                    <h1
                        className="text-foreground text-lg font-light tracking-wide italic"
                        style={{ fontFamily: 'var(--font-display)' }}
                    >
                        Studio Board
                    </h1>
                    <p
                        className="text-[10px] text-muted-foreground tracking-widest uppercase mt-0.5"
                        style={{ fontFamily: 'var(--font-mono)' }}
                    >
                        Appointment workflow
                    </p>
                </div>

                <div className="flex items-center gap-2">
          <span
              className="text-[10px] text-muted-foreground tracking-wider mr-1"
              style={{ fontFamily: 'var(--font-mono)' }}
          >
            FILTER
          </span>

                    <button
                        onClick={() => setFilterPhotographer(null)}
                        className={`px-3 py-1.5 rounded-md text-xs transition-all ${
                            filterPhotographer === null
                                ? 'bg-primary text-primary-foreground'
                                : 'text-muted-foreground hover:text-foreground bg-muted hover:bg-accent border border-border'
                        }`}
                    >
                        All
                    </button>

                    {PHOTOGRAPHERS.map(p => (
                        <button
                            key={p.id}
                            onClick={() => setFilterPhotographer(filterPhotographer === p.id ? null : p.id)}
                            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs transition-all border ${
                                filterPhotographer === p.id
                                    ? 'bg-background text-foreground font-medium shadow-sm'
                                    : 'text-muted-foreground hover:text-foreground bg-muted hover:bg-accent border-border'
                            }`}
                            style={filterPhotographer === p.id ? { borderColor: p.color } : {}}
                        >
                            <div className="w-2 h-2 rounded-full flex-shrink-0" style={{ backgroundColor: p.color }} />
                            {p.name.split(' ')[0]}
                        </button>
                    ))}
                </div>
            </header>

            {/* Stats strip */}
            <div className="border-b border-border bg-card px-6 py-2 flex items-center gap-6 flex-shrink-0">
                {COLUMNS.map(col => (
                    <div key={col.id} className="flex items-center gap-2">
                        <span className="text-[10px] text-muted-foreground">{col.label}</span>
                        <span
                            className="text-[10px] text-foreground"
                            style={{ fontFamily: 'var(--font-mono)' }}
                        >
              {appointments.filter(a => a.status === col.id).length}
            </span>
                    </div>
                ))}
                <div
                    className="ml-auto text-[10px] text-muted-foreground/60"
                    style={{ fontFamily: 'var(--font-mono)' }}
                >
                    {appointments.length} active
                </div>
            </div>

            {/* Kanban grid */}
            <main className="flex-1 overflow-hidden p-5">
                <div className="grid grid-cols-4 gap-4 h-full">
                    {COLUMNS.map(col => (
                        <Column
                            key={col.id}
                            column={col}
                            appointments={visibleAppointments.filter(a => a.status === col.id)}
                            onDragStart={handleDragStart}
                            onDrop={handleDrop}
                            onMarkDone={handleMarkDone}
                            onAssign={handleAssign}
                        />
                    ))}
                </div>
            </main>

            {/* Footer legend */}
            <footer className="border-t border-border bg-card px-6 py-2.5 flex items-center gap-5 flex-shrink-0">
                {PHOTOGRAPHERS.map(p => (
                    <div key={p.id} className="flex items-center gap-2">
                        <div className="w-2 h-2 rounded-full" style={{ backgroundColor: p.color }} />
                        <span className="text-[10px] text-muted-foreground" style={{ fontFamily: 'var(--font-mono)' }}>
              {p.name}
            </span>
                    </div>
                ))}
                <div
                    className="ml-auto text-[10px] text-muted-foreground/40 tracking-wider"
                    style={{ fontFamily: 'var(--font-mono)' }}
                >
                    DRAG TO MOVE · HOVER TO COMPLETE
                </div>
            </footer>
        </div>
    );
}
